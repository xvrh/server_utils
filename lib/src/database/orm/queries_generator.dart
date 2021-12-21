import 'package:dart_style/dart_style.dart';
import 'package:postgres/postgres.dart';
import 'package:server_utils/src/database/orm/queries_parser.dart';
import 'package:server_utils/src/database/schema/schema.dart';
import 'package:path/path.dart' as p;
import '../../utils/string.dart';
import 'data_type_postgres.dart';
import 'utils/sql_parser.dart';
import 'package:collection/collection.dart';

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
    var parsed = parseQueries(rawContent);
    if (parsed.isFailure) {
      throw QueriesGeneratorException('Fail to parse ${p.basename(filePath)} '
          '(file://${p.normalize(p.absolute(filePath))}:${parsed.toPositionString()})');
    }
    var result = parsed.value;

    var code = StringBuffer();
    var projectionsCode = StringBuffer();
    code.writeln("""
// GENERATED-CODE: do not edit
// Code is generated from $filePath.sql
import 'package:server_utils/database.dart';""");

    for (var import in result.importDirectives) {
      code.writeln('import ${import.body};');
    }

    var classDirective = result.classDirective;
    var defaultName = fileName.words.toUpperCamel();
    if (classDirective != null) {
      var className = classDirective.name?.name ?? defaultName;
      code.writeln('''
class $className {
  final Database database;
  
  $className(this.database);
''');
    } else {
      var extensionDirective = result.extensionDirective;
      code.writeln(
          'extension ${extensionDirective?.name?.name ?? defaultName} on Database {');
    }
    for (var query in result.queries) {
      var sqlParameters = query.query.parameters.map((p) => p.name).toList();
      var methodParameters =
          query.header.method.parameters.parameters.map((p) => p.name).toList();
      if (!const UnorderedIterableEquality()
          .equals(sqlParameters, methodParameters)) {
        throw Exception(
            'Error generating (file://${p.normalize(p.absolute(filePath))}) - ${query.header.method.name}:\n'
            'The declared parameters ($methodParameters) and sql parameters ($sqlParameters) has a mismatch');
      }

      var queryResult = await evaluator.runQuery(query.query);

      var projection = query.header.projection;
      var columns =
          computedColumns(schema, queryResult, projection: projection);

      if (projection != null) {
        projectionsCode.writeln(_projectionCode(projection, columns));
      }

      var returnType = ReturnType(query.header.method.returnType);
      var isSimpleType = columns.length == 1 &&
          columns.first.type.dartType == returnType.queryType;

      var queryConstructor = '';
      if (isSimpleType) {
        queryConstructor = '.singleColumn';
      } else if (returnType._isVoid) {
        queryConstructor = '.noResult';
      }

      code.writeln('${returnType.returnType} ${query.header.method.name}'
          '${query.header.method.parameters.rawDeclaration} {');
      code.writeln(
          'return Query<${returnType.queryType}>$queryConstructor(this, ');
      code.writeln('  //language=sql');
      code.writeln("r'''");
      code.writeln(query.query.body);
      code.writeln("''', arguments: {");
      for (var parameter in query.header.method.parameters.parameters) {
        code.writeln("'${parameter.name}': ${parameter.name},");
      }
      code.writeln('}');
      if (!isSimpleType && !returnType._isVoid) {
        code.writeln(', mapper: ${returnType.queryType}.fromRow,');
      }
      code.writeln(')${returnType.methodCall};');
      code.writeln('}');
    }
    code.writeln('}');

    code.writeln(projectionsCode);

    var resultCode = '$code';
    try {
      resultCode = DartFormatter().format(resultCode);
    } catch (e) {
      print('Error while formatting code: $e');
    }
    return resultCode;
  }

  String _projectionCode(
      ProjectionDeclaration projection, List<ComputedColumnInfo> columns) {
    var code = StringBuffer('');

    var className = projection.name.name;

    //TODO(xha): share the code with the table generation.
    // Needs: fromRow(), toRow(), fromJson, toJson, toString, copyWith
    code.writeln('class $className {');
    for (var column in columns) {
      //TODO(xha): describe the table to know if it's nullable or not.

      code.writeln(
          'final ${column.type.dartType}${column.isNullable ? '?' : ''} ${column.name.words.toLowerCamel()};');
    }

    code.writeln('');
    code.writeln('$className({');
    for (var column in columns) {
      code.writeln(
          '${column.isNullable ? '' : 'required '}this.${column.name.words.toLowerCamel()},');
    }
    code.writeln('});');
    code.writeln('');

    code.writeln('static $className fromRow(Map<String, dynamic> row) {');
    code.writeln('return $className(');
    for (var column in columns) {
      code.writeln('${column.name.words.toLowerCamel()}: '
          "row['${column.name}']${column.isNullable ? '' : '!'} "
          "as ${column.type.dartType}${column.isNullable ? '?' : ''},");
    }
    code.writeln(');');
    code.writeln('}');

    code.writeln('}');
    return '$code';
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

  String get queryType {
    var parameterIndex = rawType.indexOf('<');
    if (parameterIndex >= 0) {
      return rawType.substring(parameterIndex + 1, rawType.length - 1);
    } else {
      if (rawType.endsWith('?')) {
        return rawType.substring(0, rawType.length - 1);
      }
      return rawType;
    }
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
  Future<List<ColumnInfo>> runQuery(SqlQuery query);
}

class PostgresQueryEvaluator implements QueryEvaluator {
  final PostgreSQLConnection connection;

  PostgresQueryEvaluator(this.connection);

  @override
  Future<List<ColumnInfo>> runQuery(SqlQuery query) async {
    var args = <String, dynamic>{};
    for (var parameter in query.parameters) {
      args[parameter.name] = null;
    }

    late PostgreSQLResult result;
    await connection.transaction((connection) async {
      result = await connection.query(query.bodyWithDartSubstitutions,
          substitutionValues: args);
      connection.cancelTransaction();
      return result;
    });

    return result.columnDescriptions
        .map((d) => ColumnInfo(
            d.columnName,
            d.tableName,
            dataTypeFromTypeId(d.typeId,
                debugMessage: 'Column: ${d.columnName}/${d.tableName}')))
        .toList();
  }
}

class ColumnInfo {
  final String columnName;
  final String tableName;
  final DataType type;

  ColumnInfo(this.columnName, this.tableName, this.type);
}

class ComputedColumnInfo {
  final ColumnInfo _info;
  final bool isNullable;

  ComputedColumnInfo(this._info, {required this.isNullable});

  String get name => _info.columnName;
  String get tableName => _info.tableName;
  DataType get type => _info.type;
}

List<ComputedColumnInfo> computedColumns(
    DatabaseSchema schema, List<ColumnInfo> columns,
    {ProjectionDeclaration? projection}) {
  var results = <ComputedColumnInfo>[];

  for (var column in columns) {
    var tableColumn = schema[column.tableName]?[column.columnName];

    var isNullable = projection?.lineFor(column.columnName)?.nullable ??
        tableColumn?.isNullable ??
        projection?.defaultLine?.nullable ??
        true;

    results.add(ComputedColumnInfo(column, isNullable: isNullable));
  }

  return results;
}
