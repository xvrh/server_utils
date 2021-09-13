import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:postgres/postgres.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import '../database_io.dart';
import 'data_type_postgres.dart';
import 'sql_file_parser.dart';
import '../../utils/string.dart';

Future<void> generateSqlQueryFile(
    PostgreSQLConnection connection, File file) async {
  var generator = SqlFileGenerator(connection);
  var code = await generator.generate(parseSqlFile(file.readAsStringSync()),
      fileName: p.basenameWithoutExtension(file.path));
  File(p.join(p.dirname(file.path),
          '${p.basenameWithoutExtension(file.path)}.dart'))
      .writeAsStringSync(code);
}

class SqlFileGenerator {
  final PostgreSQLConnection connection;

  SqlFileGenerator(this.connection);

  Future<String> generate(SqlFile file, {required String fileName}) async {
    var code = StringBuffer();
    var projectionsCode = StringBuffer();
    code.writeln("""
// GENERATED-CODE: do not edit
// Code is generated from $fileName.sql
import 'package:server_utils/database.dart';""");
    for (var import in file.imports) {
      code.writeln(import);
    }

    code.writeln('extension ${fileName.words.toUpperCamel()} on Database {');
    for (var query in file.queries) {
      var outputName = query.method.result.name;
      var queryResult = await runQuery(query);

      var isSingleColumn = queryResult.columns.length == 1;

      if (query.method.result.isGenerated) {
        outputName ??= '${query.method.name.words.toUpperCamel()}Row';
        projectionsCode.writeln(_projectionCode(outputName, queryResult));
      } else if (isSingleColumn) {
        var firstColumn = queryResult.columns.first;
        var type = dataTypeFromTypeId(firstColumn.typeId);
        var isNullable = queryResult.isColumnNullable(firstColumn);
        outputName = '${type.dartType}${isNullable ? '?' : ''}';
      } else {
        outputName ??= await _inferClassName(query, queryResult);
      }
      var querySuffix = '';
      String outputType;
      var isFuture = true;
      switch (query.method.result.type) {
        case ResultType.singleOrNull:
          outputType = '$outputName?';
          querySuffix = '.singleOrNull';
          break;
        case ResultType.single:
          outputType = outputName;
          querySuffix = '.single';
          break;
        case ResultType.page:
          outputType = 'Page<$outputName>';
          querySuffix = '.page(page)';
          break;
        case ResultType.list:
          outputType = 'List<$outputName>';
          querySuffix = '.list';
          break;
        case ResultType.all:
          isFuture = false;
          outputType = 'Query<$outputName>';
      }

      var returnType = isFuture ? 'Future<$outputType>' : outputType;
      code.writeln('$returnType ${query.method.name}(');
      if (query.parameters.isNotEmpty) {
        code.writeln('{');
      }
      for (var parameter in query.parameters) {
        code.writeln(
            'required ${parameter.type.dartType} ${parameter.name.words.toLowerCamel()},');
      }
      if (query.parameters.isNotEmpty) {
        code.writeln('}');
      }
      code.writeln(') {');
      code.writeln(
          'return Query<$outputName>${isSingleColumn ? '.singleColumn' : ''}(this, ');
      code.writeln('  //language=sql');
      code.writeln("r'''");
      code.writeln(query.query);
      code.writeln("''', arguments: {");
      for (var parameter in query.parameters) {
        code.writeln(
            "'${parameter.name}': ${parameter.name.words.toLowerCamel()},");
      }
      code.writeln('}');
      if (!isSingleColumn) {
        code.writeln(', mapper: $outputName.fromRow,');
      }
      code.writeln(')$querySuffix;');
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

  Future<QueryResult> runQuery(SqlQuery query) async {
    var args = <String, dynamic>{};
    for (var parameter in query.parameters) {
      args[parameter.name] = null;
    }

    late PostgreSQLResult result;
    await connection.transaction((connection) async {
      result = await connection.query(
          DatabaseIO.replaceNormalParametersWithSubstitution(query.query),
          substitutionValues: args);
      connection.cancelTransaction();
      return result;
    });

    return QueryResult(query, result.columnDescriptions);
  }

  String _inferClassName(SqlQuery query, QueryResult result) {
    var tableName = result.columns.first.tableName;
    var otherColumn =
        result.columns.firstWhereOrNull((c) => c.tableName != tableName);
    if (otherColumn != null) {
      throw Exception('You need to specify a return type. '
          '[${query.method.name}] inferred table name [$tableName] but [${otherColumn.columnName}] is from [${otherColumn.tableName}]. '
          'Method [${query.method.name}] has return type [${query.method.result}]'
          'This means the script tried to discover automatically the return type but failed');
    }
    //TODO(xha): describe the table to check that all the fields are listed
    return result.columns.first.tableName;
  }

  String _projectionCode(String className, QueryResult queryResult) {
    var code = StringBuffer('');

    //TODO(xha): share the code with the table generation.
    // Needs: fromRow(), toRow(), fromJson, toJson, toString, copyWith
    code.writeln('class $className {');
    for (var column in queryResult.columns) {
      var type = dataTypeFromTypeId(column.typeId);
      var isNullable = queryResult.isColumnNullable(column);

      //TODO(xha): describe the table to know if it's nullable or not.

      code.writeln(
          'final ${type.dartType}${isNullable ? '?' : ''} ${column.columnName.words.toLowerCamel()};');
    }

    code.writeln('');
    code.writeln('$className({');
    for (var column in queryResult.columns) {
      var isNullable = queryResult.isColumnNullable(column);

      code.writeln(
          '${isNullable ? '' : 'required '}this.${column.columnName.words.toLowerCamel()},');
    }
    code.writeln('});');
    code.writeln('');

    code.writeln('static $className fromRow(Map<String, dynamic> row) {');
    code.writeln('return $className(');
    for (var column in queryResult.columns) {
      var type = dataTypeFromTypeId(column.typeId);
      var isNullable = queryResult.isColumnNullable(column);

      code.writeln(
          "${column.columnName.words.toLowerCamel()}: row['${column.columnName}']${isNullable ? '' : '!'} as ${type.dartType}${isNullable ? '?' : ''},");
    }
    code.writeln(');');
    code.writeln('}');

    code.writeln('}');
    return '$code';
  }
}

class QueryResult {
  final SqlQuery query;
  final List<ColumnDescription> columns;

  QueryResult(this.query, this.columns);

  //TODO(xha): check in known tables
  bool isColumnNullable(ColumnDescription column) =>
      query.isColumnNullable(column.columnName) ?? true;
}
