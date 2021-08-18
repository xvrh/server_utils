import 'package:dart_style/dart_style.dart';
import 'package:postgres/postgres.dart';
import 'package:collection/collection.dart';

import '../database_io.dart';
import 'data_type_postgres.dart';
import 'sql_file_parser.dart';
import '../../utils/string.dart';

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
      if (query.method.result.isGenerated) {
        outputName ??= '${query.method.name.words.toUpperCamel()}Row';
        projectionsCode.writeln(_projectionCode(outputName, queryResult));
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
      code.writeln(') {');
      code.writeln("return Query<$outputName>(r'''");
      code.writeln(query.query);
      code.writeln("''', {");

      code.writeln('})$querySuffix;');
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

    var result = await connection.query(
        DatabaseIO.replaceNormalParametersWithSubstitution(query.query),
        substitutionValues: args);
    return QueryResult(result.columnDescriptions);
  }

  String _inferClassName(SqlQuery query, QueryResult result) {
    // TODO(xha): detect single column query

    var tableName = result.columns.first.tableName;
    var otherColumn =
        result.columns.firstWhereOrNull((c) => c.tableName != tableName);
    if (otherColumn != null) {
      throw Exception(
          '${query.method.name} inferred name $tableName but ${otherColumn.columnName} is from ${otherColumn.tableName}');
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

      //TODO(xha): describe the table to know if it's nullable or not.

      code.writeln(
          'final ${type.dartType}? ${column.columnName.words.toLowerCamel()};');
    }
    code.writeln('}');
    return '$code';
  }
}

class QueryResult {
  final List<ColumnDescription> columns;

  QueryResult(this.columns);
}
