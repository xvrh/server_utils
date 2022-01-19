import 'package:collection/collection.dart';
import '../../utils/escape_dart_string.dart';
import '../../utils/quick_dart_formatter.dart';
import '../../utils/string.dart';
import '../../utils/type.dart';
import '../schema/schema.dart';
import 'enum_extractor.dart';

class DartGenerator {
  Future<String> generateEntities(List<TableDefinition> tables,
      {List<EnumDefinition>? enums}) async {
    enums ??= [];
    var code = StringBuffer('''
// GENERATED-FILE
''');

    for (var table in tables) {
      var enumDefinition = enums.firstWhereOrNull((e) => e.table == table);
      if (enumDefinition != null) {
        code.writeln(generateEnum(table, enumDefinition));
      } else {
        code.writeln(generateClassFromColumns(table.name, table.columns));
      }
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

  String generateClassFromColumns(String name, List<ColumnDefinition> columns) {
    var code = StringBuffer('');

    var className = name.words.toUpperCamel();

    code.writeln('class $className {');
    for (var column in columns) {
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

    code.writeln('factory $className.fromRow(Map<String, dynamic> row) {');
    code.writeln('return $className(');
    for (var column in columns) {
      code.writeln('${column.name.words.toLowerCamel()}: '
          "row['${column.name}']${column.isNullable ? '' : '!'} "
          "as ${column.type.dartType}${column.isNullable ? '?' : ''},");
    }
    code.writeln(');');
    code.writeln('}');
    code.writeln('');

    code.writeln('factory $className.fromJson(Map<String, Object?> json) {');
    code.writeln('return $className(');
    for (var column in columns) {
      var accessor = "json['${column.name.words.toLowerCamel()}']";
      var type = ValueType.fromTypeName(column.type.dartType,
          isNullable: column.isNullable);

      var fromJsonCode =
          type.fromJsonCode(Value(accessor, ObjectType(isNullable: true)));

      code.writeln('${column.name.words.toLowerCamel()}: $fromJsonCode,');
    }
    code.writeln(');');
    code.writeln('}');
    code.writeln('');

    code.writeln(' Map<String, Object?> toJson() {');
    code.writeln('return {');
    for (var column in columns) {
      var type = ValueType.fromTypeName(column.type.dartType,
          isNullable: column.isNullable);

      var toJsonCode = type.toJsonCode(column.name.words.toLowerCamel());
      code.writeln("'${column.name.words.toLowerCamel()}': $toJsonCode,");
    }
    code.writeln('};');
    code.writeln('}');

    code.writeln('}');
    return '$code';
  }

  String generateEnum(TableDefinition table, EnumDefinition enumDefinition) {
    var code = StringBuffer('');

    var className = table.name.words.toUpperCamel();
    var columns = table.columns;

    // Enums only support a single primary key of type String
    var primaryKey = columns.singleWhere((e) => e.isPrimaryKey);
    if (primaryKey.type.dartType != 'String') {
      throw Exception('Exception must have single primary key of type String');
    }
    var valueField = primaryKey.name.words.toLowerCamel();

    code.writeln('class $className {');
    var enumPrimaryKey = enumDefinition.primaryKey;
    for (var enumLine in enumDefinition.rows) {
      var primaryKeyValue = enumLine[enumPrimaryKey]! as String;

      var arguments = <String>[];
      for (var entry in enumLine.entries) {
        arguments.add(
            '${entry.key.name.words.toLowerCamel()}: ${_toDartLiteral(entry.value)}');
      }
      code.writeln(
          'static const ${primaryKeyValue.words.toLowerCamel()} = $className._(${arguments.join(', ')});');
    }
    code.writeln('');
    code.writeln('static const values = [');
    for (var enumLine in enumDefinition.rows) {
      var primaryKeyValue = enumLine[enumPrimaryKey]! as String;
      code.writeln('${primaryKeyValue.words.toLowerCamel()},');
    }
    code.writeln('];');
    code.writeln('');

    for (var column in columns) {
      code.writeln(
          'final ${column.type.dartType}${column.isNullable ? '?' : ''} ${column.name.words.toLowerCamel()};');
    }

    code.writeln('');
    code.writeln('const $className._({');
    for (var column in columns) {
      code.writeln(
          '${column.isNullable ? '' : 'required '}this.${column.name.words.toLowerCamel()},');
    }
    code.writeln('});');
    code.writeln('');

    var fromRowArgs = <String>[];
    for (var column in table.columns) {
      fromRowArgs.add('${column.name.words.toLowerCamel()}: '
          "row['${column.name}']${column.isNullable ? '' : '!'} "
          "as ${column.type.dartType}${column.isNullable ? '?' : ''}");
    }

    var fromJsonArgs = <String>[];
    for (var column in table.columns) {
      var accessor = "json['${column.name.words.toLowerCamel()}']";
      var type = ValueType.fromTypeName(column.type.dartType,
          isNullable: column.isNullable);
      var code =
          type.fromJsonCode(Value(accessor, ObjectType(isNullable: true)));

      fromJsonArgs.add('${column.name.words.toLowerCamel()}: $code');
    }

    var toJsonArgs = <String>[];
    for (var column in table.columns) {
      var type = ValueType.fromTypeName(column.type.dartType,
          isNullable: column.isNullable);

      var toJsonCode = type.toJsonCode(column.name.words.toLowerCamel());
      toJsonArgs.add("'${column.name.words.toLowerCamel()}': $toJsonCode");
    }

    code.writeln('''
static $className fromRow(Map<String, dynamic> row) =>
  values.firstWhere((e) => e.$valueField == row['${primaryKey.name}']! as String,
    orElse: () => $className._(${fromRowArgs.join(',')}));

static $className fromJson(Map<String, Object?> json) =>
  values.firstWhere((e) => e.$valueField == json['${primaryKey.name.words.toLowerCamel()}']! as String,
    orElse: () => $className._(${fromJsonArgs.join(',')}));
    
Map<String, Object?> toJson() => { ${toJsonArgs.join(',')}${toJsonArgs.length > 1 ? ',' : ''} };

bool get isUnknown => values.every((v) => v.$valueField != $valueField);

@override
String toString() => $valueField;
''');

    code.writeln('}');
    return '$code';
  }

  Future<String> generateCrudFile(List<TableDefinition> tables,
      {required List<String> imports, String? extensionName}) async {
    var code = StringBuffer('''
// GENERATED-FILE

import 'package:server_utils/database.dart';
''');

    for (var import in imports) {
      code.writeln("import '$import';");
    }

    extensionName ??= 'DatabaseCrudExtension';
    code.writeln('extension $extensionName on Database {');
    for (var table in tables) {
      var className = '${table.name.words.toUpperCamel()}Crud';
      code.writeln(
          '$className get ${table.name.words.toLowerCamel()} => $className(this);');
      code.writeln();
    }
    code.writeln('}');

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

    var className = '${table.name.words.toUpperCamel()}Crud';
    var columns = table.columns;
    var primaryKeys = columns.where((c) => c.isPrimaryKey).toList();

    code.writeln('''
class $className {
  final Database _database;

  $className(this._database);    
''');

    _findCode(code, table, primaryKeys);
    _insertCode(code, table);
    if (columns.where((c) => !c.isPrimaryKey).isNotEmpty) {
      _updateCode(code, table);
    }
    _deleteCode(code, table, primaryKeys);

    code.writeln('}');
    return '$code';
  }

  void _findCode(StringBuffer code, TableDefinition table,
      List<ColumnDefinition> primaryKeys) {
    var entityName = table.name.words.toUpperCamel();

    code.writeln(
        'Future<$entityName> find(${primaryKeys.map((p) => '${p.type.dartType} ${p.name.words.toLowerCamel()}').join(', ')}) {');
    code.writeln('return _database.single(');
    code.writeln('  //language=sql');

    var where = primaryKeys
        .map((p) =>
            '${p.name} = :${p.name.words.toLowerCamel()}::${p.type.postgresType}')
        .join(' and ');
    code.writeln("'select * from ${table.name} where $where',");
    code.writeln('  //language=none');
    code.writeln('args: {');
    for (var p in primaryKeys) {
      code.writeln("'${p.name}': ${p.name.words.toLowerCamel()},");
    }
    code.writeln('},');
    code.writeln('mapper: $entityName.fromRow,');
    code.writeln(');');
    code.writeln('}');
    code.writeln('');
  }

  void _insertCode(StringBuffer code, TableDefinition table) {
    var entityName = table.name.words.toUpperCamel();

    code.writeln('Future<$entityName> insert({');
    for (var column in table.columns) {
      var fieldName = column.name.words.toLowerCamel();
      if (column.isNullable || column.defaultValue != null) {
        var type = column.type.dartType;
        if (type == 'dynamic') {
          type = 'Object';
        }
        type += '?';
        var comment = '';
        if (column.defaultValue != null) {
          comment = '/* ${column.defaultValue} */';
        }
        code.writeln('$type $fieldName $comment,');
      } else {
        code.writeln('required ${column.type.dartType} $fieldName,');
      }
    }
    code.writeln('}) {');
    code.writeln("return _database.insert('${table.name}',");
    code.writeln('values: {');
    for (var column in table.columns) {
      var variableName = column.name.words.toLowerCamel();
      if (column.isNullable || column.defaultValue != null) {
        code.writeln('if ($variableName != null)');
      }
      code.writeln("'${column.name}': $variableName,");
    }
    code.writeln('},');
    code.writeln('mapper: $entityName.fromRow,');
    code.writeln(');');
    code.writeln('}');
    code.writeln('');
  }

  void _updateCode(StringBuffer code, TableDefinition table) {
    var entityName = table.name.words.toUpperCamel();

    code.write('Future<$entityName> update(');
    for (var primaryKey in table.columns.where((c) => c.isPrimaryKey)) {
      code.write(
          '${primaryKey.type.dartType} ${primaryKey.name.words.toLowerCamel()},');
    }
    code.write('{');
    var clears = <ColumnDefinition>[];
    for (var column in table.columns.where((c) => !c.isPrimaryKey)) {
      code.write(
          '${column.type.dartType}? ${column.name.words.toLowerCamel()},');
      if (column.isNullable) {
        clears.add(column);
        code.write('bool? clear${column.name.words.toUpperCamel()},');
      }
    }
    code.writeln('}) {');
    code.writeln("return _database.update('${table.name}',");
    code.writeln('where: {');
    for (var primaryKey in table.columns.where((c) => c.isPrimaryKey)) {
      code.write(
          "'${primaryKey.name}': ${primaryKey.name.words.toLowerCamel()},");
    }
    code.writeln('},');
    code.writeln('set: {');
    for (var column in table.columns.where((c) => !c.isPrimaryKey)) {
      var variable = column.name.words.toLowerCamel();
      code.write("if ($variable != null) '${column.name}': $variable,");
    }
    code.writeln('},');
    if (clears.isNotEmpty) {
      code.writeln('clear: [');
      for (var column in clears) {
        code.write(
            "if (clear${column.name.words.toUpperCamel()} ?? false)'${column.name}',");
      }
      code.writeln('],');
    }
    code.writeln('mapper: $entityName.fromRow,');
    code.writeln(');');
    code.writeln('}');
    code.writeln('');
    code.writeln('Future<$entityName> updateEntity($entityName entity) {');
    code.writeln('throw UnimplementedError();');
    code.writeln('}');
    code.writeln('');
  }

  void _deleteCode(StringBuffer code, TableDefinition table,
      List<ColumnDefinition> primaryKeys) {
    code.writeln(
        'Future<int> delete(${primaryKeys.map((p) => '${p.type.dartType} ${p.name.words.toLowerCamel()}').join(', ')}) {');
    code.writeln('return _database.execute(');
    code.writeln('  //language=sql');
    var where = primaryKeys
        .map((p) =>
            '${p.name} = :${p.name.words.toLowerCamel()}::${p.type.postgresType}')
        .join(' and ');
    code.writeln("'delete from ${table.name} where $where',");
    code.writeln('  //language=none');
    code.writeln('args: {');
    for (var p in primaryKeys) {
      code.writeln("'${p.name}': ${p.name.words.toLowerCamel()},");
    }
    code.writeln('},');
    code.writeln(');');
    code.writeln('}');
    code.writeln('');
  }
}

String _toDartLiteral(Object? value) {
  if (value == null) return 'null';
  if (value is String) return escapeDartString(value);
  return '$value';
}
