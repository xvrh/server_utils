import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart';
//TODO(xha): expose columnID from FieldDescription
// ignore: implementation_imports
import 'package:postgres/src/query.dart' show FieldDescription;
import '../../../database_builder.dart';
import '../../utils/quick_dart_formatter.dart';
import 'dart_generator.dart';
import 'data_type_postgres.dart';
import 'queries_parser.dart';
import 'utils/sql_parser.dart';

class QueriesGeneratorException implements Exception {
  final String message;

  QueriesGeneratorException(this.message);

  @override
  String toString() => message;
}

class QueriesGenerator {
  final DatabaseSchema schema;
  final QueryEvaluator evaluator;

  QueriesGenerator(this.schema, this.evaluator);

  Future<String> generate(String rawContent, {required String filePath}) async {
    var fileName = p.basenameWithoutExtension(filePath);
    QueriesFile result;
    try {
      result = parseQueries(rawContent);
    } catch (e) {
      throw QueriesGeneratorException('Fail to parse ${p.basename(filePath)} '
          '(file://${p.normalize(p.absolute(filePath))}:$e)');
    }

    var code = StringBuffer();
    var projectionsCode = StringBuffer();
    code.writeln("""
// GENERATED-CODE: do not edit
// Code is generated from ${p.basename(filePath)}

part of '$fileName.dart';""");

    for (var extension in result.extensions) {
      var extensionName = extension.name;
      if (!extensionName.startsWith('_')) {
        code.writeln('// Skip extension [$extensionName] (need to be private)');

        continue;
      }
      extensionName = extensionName.substring(1);
      code.writeln('extension $extensionName on Database {');

      for (var query in extension.queries) {
        var sqlParameters = query.query.parameters.map((p) => p.name).toSet();
        var methodParameters = query.header.method.parameters.parameters
            .map((p) => p.name)
            .toSet();
        var errorHeader =
            'Error generating (file://${p.normalize(p.absolute(filePath))}) - ${query.header.method.name}:\n';
        if (!const UnorderedIterableEquality()
            .equals(sqlParameters, methodParameters)) {
          throw Exception(
              '${errorHeader}The declared parameters ($methodParameters) and sql parameters ($sqlParameters) has a mismatch');
        }
        var testValues =
            query.header.testValues?.values.map((p) => p.name).toSet();
        if (testValues != null && !testValues.every(sqlParameters.contains)) {
          throw Exception(
              '${errorHeader}The test values ($testValues) and sql parameters ($sqlParameters) has a mismatch');
        }

        List<ColumnInfo> queryResult;
        try {
          queryResult = await evaluator.runQuery(query.query, query.header);
        } catch (e, s) {
          Error.throwWithStackTrace(
              QueriesGeneratorException('[${query.header.method.name}]: $e'),
              s);
        }

        var projection = query.header.projection;
        var columns =
            computedColumns(schema, queryResult, projection: projection);
        var returnType = ReturnType(query.header.method.returnType);

        if (projection != null) {
          projectionsCode.writeln(_projectionCode(
              returnType.innerTypeWithoutNullability, projection, columns));
        }

        var isSimpleType = columns.length == 1 &&
            columns.first.type.dartType ==
                returnType.innerTypeWithoutNullability;

        var queryConstructor = '';
        if (isSimpleType) {
          queryConstructor = '.singleColumn';
        } else if (returnType._isVoid) {
          queryConstructor = '.noResult';
        }

        code.writeln('${returnType.returnType} ${query.header.method.name}'
            '${query.header.method.parameters.rawDeclaration} {');
        code.writeln(
            'return Query<${returnType.innerType}>$queryConstructor(this, ');
        code.writeln('  //language=sql');
        code.writeln("r'''");
        code.writeln(query.query.body);
        code.writeln("''', arguments: {");
        for (var parameter in query.header.method.parameters.parameters) {
          code.writeln("'${parameter.name}': ${parameter.name},");
        }
        code.writeln('}');
        if (!isSimpleType && !returnType._isVoid) {
          code.writeln(
              ', mapper: ${returnType.innerTypeWithoutNullability}.fromRow,');
        }
        code.writeln(')${returnType.methodCall};');
        code.writeln('}');
      }

      code.writeln('''
  // ignore: unused_element
void _simulateUseElements() {
  ${extension.queries.map((q) => 'print(${extension.name}(this).${q.header.method.name});').join('\n')}
}      
''');
      code.writeln('}');

      code.writeln(projectionsCode);
    }

    var resultCode = '$code';
    try {
      resultCode = await formatDartCode(resultCode);
    } catch (e) {
      print('Error while formatting code: $e');
    }
    return resultCode;
  }

  String _projectionCode(String projectionName,
      ProjectionDeclaration projection, List<ColumnDefinition> columns) {
    var dartGenerator = DartGenerator(ConfiguredSchema.empty);
    return dartGenerator.generateClassFromColumns(projectionName, columns,
        table: null);
  }
}

class ReturnType {
  final String rawType;

  ReturnType(this.rawType);

  bool get _isQuery => rawType.startsWith('Query<');
  bool get _isPage => rawType.startsWith('Page<');
  bool get _isVoid => rawType == 'void';

  String get returnType {
    if (_isQuery) {
      return rawType;
    } else if (_isVoid) {
      return 'Future<int>';
    } else {
      return 'Future<$rawType>';
    }
  }

  static String removeNullability(String type) {
    if (type.endsWith('?')) {
      return type.substring(0, type.length - 1);
    }
    return type;
  }

  String get innerType {
    var parameterIndex = rawType.indexOf('<');
    if (parameterIndex >= 0) {
      return rawType.substring(parameterIndex + 1, rawType.length - 1);
    } else {
      return rawType;
    }
  }

  String get innerTypeWithoutNullability {
    return removeNullability(innerType);
  }

  String get methodCall {
    if (_isQuery) {
      return '';
    } else if (_isPage) {
      return '.page(page)';
    } else if (rawType.startsWith('List<')) {
      return '.list';
    } else if (_isVoid) {
      return '.affectedRows';
    } else {
      if (rawType.endsWith('?')) {
        return '.singleOrNull';
      } else {
        return '.single';
      }
    }
  }
}

abstract class QueryEvaluator {
  Future<List<ColumnInfo>> runQuery(SqlQuery query, QueryHeader queryHeader);
}

class PostgresQueryEvaluator implements QueryEvaluator {
  final DatabaseSchema schema;
  final PostgreSQLConnection connection;

  PostgresQueryEvaluator(this.schema, this.connection);

  @override
  Future<List<ColumnInfo>> runQuery(
      SqlQuery query, QueryHeader queryHeader) async {
    var args = <String, dynamic>{};
    for (var parameter in query.parameters) {
      var testValue = queryHeader.testValues?.values
          .firstWhereOrNull((p) => p.name == parameter.name);
      dynamic defaultValue;
      if (testValue != null) {
        defaultValue = testValue.value;
      } else {
        var dartParameter = queryHeader.method.parameters.parameters
            .firstWhere((p) => p.name == parameter.name);
        switch (dartParameter.type) {
          case 'String':
            defaultValue = '';
            break;
          case 'int':
            defaultValue = 0;
            break;
          case 'double':
            defaultValue = 0.0;
            break;
          case 'bool':
            defaultValue = false;
            break;
        }
      }

      args[parameter.name] = defaultValue;
    }

    late PostgreSQLResult result;
    await connection.transaction((connection) async {
      result = await connection.query(query.bodyWithDartSubstitutions,
          substitutionValues: args);
      connection.cancelTransaction();
      return result;
    });

    return result.columnDescriptions.map((d) {
      var description = d as FieldDescription;
      DataType dataType;

      var enumUserType =
          schema.enums.firstWhereOrNull((e) => e.typeId == d.typeId);
      if (enumUserType != null) {
        dataType = DataType.text;
      } else {
        dataType = dataTypeFromTypeId(d.typeId,
            debugMessage: 'Column: ${d.columnName}/${d.tableName}');
      }

      return ColumnInfo(
          description.columnID, d.columnName, d.tableName, dataType,
          enumDefinition: enumUserType);
    }).toList();
  }
}

class ColumnInfo {
  final int columnId;
  final String columnName;
  final String tableName;
  final DataType type;
  final EnumDefinition? enumDefinition;

  ColumnInfo(this.columnId, this.columnName, this.tableName, this.type,
      {this.enumDefinition});
}

List<ColumnDefinition> computedColumns(
    DatabaseSchema schema, List<ColumnInfo> columns,
    {ProjectionDeclaration? projection}) {
  var results = <ColumnDefinition>[];

  for (var column in columns) {
    var table = schema[column.tableName];
    var tableColumn =
        table?.columns.firstWhereOrNull((c) => c.id == column.columnId);
    tableColumn ??= table?[column.columnName];

    var isNullable = projection?.lineFor(column.columnName)?.nullable ??
        tableColumn?.isNullable ??
        projection?.defaultLine?.nullable ??
        true;

    results.add(ColumnDefinition(column.columnId, column.columnName,
        type: column.type,
        isNullable: isNullable,
        enumDefinition: column.enumDefinition ?? tableColumn?.enumDefinition));
  }

  return results;
}
