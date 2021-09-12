import 'schema.dart';
import '../../utils/string.dart';
import '../../utils/string/case_format.dart';
import 'package:dart_style/dart_style.dart';

final _dartFormatter = DartFormatter();

String tablesToCode(List<TableDefinition> tables) {
  var buffer = StringBuffer();

  buffer.writeln('''
import 'package:database/src/schema/schema.dart';
''');

  for (var table in tables) {
    buffer.writeln(tableToCode(table));
  }

  return _dartFormatter.format(buffer.toString());
}

String tableToCode(TableDefinition table) {
  var buffer = StringBuffer();

  buffer.writeln('class ${_classCase(table.name)}Definition {');
  buffer.writeln("static const table = '${table.name}';");
  for (var column in table.columnList) {
    buffer.writeln(
        "static const ${_variableCase(column.name)} = '${column.name}';");
  }
  buffer.writeln('}');

  var tableClassName = '_${_classCase(table.name)}Table';
  var columnsClassName = '_${_classCase(table.name)}Columns';

  buffer.writeln('''
const ${_variableCase(table.name)} = $tableClassName();

class $tableClassName implements TableDefinition {
  final $columnsClassName columns = const $columnsClassName();
  final String name = '${table.name}';

  const $tableClassName();

  List<ColumnDefinition> get columnList => columns._columns;
  
  @override
  String toString() => name;
}

class $columnsClassName implements ColumnDefinitions {
''');

  for (var column in table.columnList) {
    var parameters = {
      'type': 'DataType.${_variableCase(column.type.postgresType)}',
      'postgresType': _encodeParameterValue(column.type.postgresType),
      if (!column.isNullable) 'isNullable': column.isNullable,
      if (column.isPrimaryKey) 'isPrimaryKey': column.isPrimaryKey,
      if (column.defaultValue != null)
        'defaultValue': _encodeParameterValue(column.defaultValue),
    };

    buffer.writeln('  final ${_variableCase(column.name)} ='
        "const ColumnDefinition('${column.name}', "
        "${parameters.keys.map((k) => '$k: ${parameters[k]}').join(', ')});");
  }

  buffer.writeln('''

  const $columnsClassName();
  
  List<ColumnDefinition> get _columns => [${table.columnList.map((c) => _variableCase(c.name)).join(', ')}];
''');

  buffer.writeln('}');

  return buffer.toString();
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
