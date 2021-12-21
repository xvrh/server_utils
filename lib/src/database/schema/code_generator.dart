import 'schema.dart';
import '../../utils/string.dart';
import '../../utils/string/case_format.dart';
import 'package:dart_style/dart_style.dart';

final _dartFormatter = DartFormatter();

class DartClassGenerator {
  String generateFile(List<TableDefinition> tables) {
    var buffer = StringBuffer();

    for (var table in tables) {
      buffer.writeln(generateClass(table));
    }

    return _dartFormatter.format(buffer.toString());
  }

  String generateClass(TableDefinition table) {
    var buffer = StringBuffer();

    var className = _classCase(table.name);
    buffer.writeln('''
class $className {
''');

    // .fromRow, toRow, fromJson, toJson
    for (var column in table.columns) {}

    buffer.writeln('}');

    return buffer.toString();
  }
}

String _encodeParameterValue(value) {
  if (value is String) {
    return "'${value.replaceAll("'", r"\'")}'";
  } else {
    return '$value';
  }
}

String _variableCase(String input) => lowerCamel(input.words);

String _classCase(String input) => upperCamel(input.words);
