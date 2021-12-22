import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:server_utils/src/database/schema/schema.dart';
import 'package:server_utils/src/database/schema/schema_extractor.dart';
import 'package:server_utils/src/utils/quick_dart_formatter.dart';
import '../../utils/string.dart';
import '../database_io.dart';

Future<void> generateCrudQueries(
    PostgreSQLConnection connection, File destination) async {
  var schema = await SchemaExtractor(DatabaseIO(connection)).schema();
  var dartGenerator = CrudGenerator();
  var code = await dartGenerator.generateFile(schema.tables);
  destination.writeAsStringSync(code);
}

class CrudGenerator {
  Future<String> generateFile(List<TableDefinition> tables) async {
    var code = StringBuffer('''
// GENERATED-FILE
''');

    for (var table in tables) {
      code.writeln(generateCrudForTable(table));
      code.writeln();
    }
    var resultCode = '$code';
    try {
      resultCode = await formatDartCode(resultCode);
    } catch (e) {
      print('Error while formatting code: $e');
    }
    return resultCode;
  }

  String generateCrudForTable(TableDefinition table) {
    var code = StringBuffer('');

    var className = table.name.words.toUpperCamel();
    var columns = table.columns;

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
