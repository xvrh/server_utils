import 'package:collection/collection.dart';
import '../../utils/escape_dart_string.dart';
import '../../utils/quick_dart_formatter.dart';
import '../../utils/string.dart';
import '../../utils/type.dart';
import '../schema/schema.dart';
import 'enum_extractor.dart';

class ConfiguredTable {
  final TableDefinition table;
  final TableConfig config;

  ConfiguredTable(this.table, this.config);
}

class TableConfig {
  final bool skipPrimaryInEntity;

  TableConfig({bool? skipPrimaryInEntity})
      : skipPrimaryInEntity = skipPrimaryInEntity ?? false;
}

extension TableConfigExtension on DatabaseSchema {
  List<ConfiguredTable> withConfig(Map<String, TableConfig> configs) {
    configs = Map.of(configs);
    var configuredTables = <ConfiguredTable>[];
    for (var table in tables) {
      var config = configs.remove(table.name);
      configuredTables.add(ConfiguredTable(table, config ?? TableConfig()));
    }
    if (configs.isNotEmpty) {
      throw Exception(
          '${configs.entries.map((e) => e.key).join(', ')} are not table');
    }

    return configuredTables;
  }
}

class DartGenerator {
  final List<EnumDefinition> enums;
  final List<ConfiguredTable> tables;

  DartGenerator({List<EnumDefinition>? enums, List<ConfiguredTable>? tables})
      : enums = enums ?? const [],
        tables = tables ?? const [];

  Future<String> generateEntities() async {
    var code = StringBuffer('''
// GENERATED-FILE
import 'package:server_utils/database.dart';
''');

    for (var configuredTable in tables) {
      var table = configuredTable.table;
      var enumDefinition = enums.firstWhereOrNull((e) => e.table == table);
      if (enumDefinition != null) {
        code.writeln(generateEnum(configuredTable, enumDefinition));
      } else {
        var columns = table.columns.toList();
        if (configuredTable.config.skipPrimaryInEntity) {
          columns.removeWhere((e) => e.isPrimaryKey);
        }

        code.writeln(generateClassFromColumns(table.name, columns));
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

    var fields = <_ColumnField>[];
    for (var column in columns) {
      fields.add(_ColumnField(column,
          reference:
              enums.firstWhereOrNull((e) => e.table.name == column.reference)));
    }
    var className = name.words.toUpperCamel();

    code.writeln('class $className {');
    code.writeln('static final columns = _${className}Columns();');
    code.writeln('');
    for (var field in fields) {
      code.writeln(
          'final ${field.type}${field.isNullable ? '?' : ''} ${field.name};');
    }

    code.writeln('');
    code.writeln('$className({');
    for (var field in fields) {
      code.writeln('${field.isNullable ? '' : 'required '}this.${field.name},');
    }
    code.writeln('});');
    code.writeln('');

    code.writeln('factory $className.fromRow(Map<String, dynamic> row) {');
    code.writeln('return $className(');
    for (var field in fields) {
      code.writeln('${field.name}: ');
      var reference = field.reference;
      if (reference == null) {
        code.writeln(
            "row['${field.column.name}']${field.isNullable ? '' : '!'} "
            "as ${field.type}${field.isNullable ? '?' : ''},");
      } else {
        code.writeln('${reference.table.name.words.toUpperCamel()}'
            "(row['${field.column.name}']${field.isNullable ? '' : '!'} as String),");
      }
    }
    code.writeln(');');
    code.writeln('}');
    code.writeln('');

    code.writeln('factory $className.fromJson(Map<String, Object?> json) {');
    code.writeln('return $className(');
    for (var field in fields) {
      var accessor = "json['${field.name}']";

      var fromJsonCode = field.jsonType
          .fromJsonCode(Value(accessor, ObjectType(isNullable: true)));

      code.writeln('${field.name}: $fromJsonCode,');
    }
    code.writeln(');');
    code.writeln('}');
    code.writeln('');

    code.writeln(' Map<String, Object?> toJson() {');
    code.writeln('return {');
    for (var field in fields) {
      var toJsonCode = field.jsonType.toJsonCode(field.name);
      code.writeln("'${field.name}': $toJsonCode,");
    }
    code.writeln('};');
    code.writeln('}');

    code.writeln(' $className copyWith({');
    for (var field in fields) {
      code.write('${field.type}? ${field.name},');
      if (field.isNullable) {
        code.write('bool? clear${field.name.words.toUpperCamel()},');
      }
    }
    code.writeln('}) {');
    code.writeln('return $className(');
    for (var field in fields) {
      var coalesce = '${field.name} ?? this.${field.name}';
      if (field.isNullable) {
        coalesce =
            '(clear${field.name.words.toUpperCamel()} ?? false) ? null : $coalesce';
      }
      code.writeln('${field.name}: $coalesce,');
    }
    code.writeln(');}');

    code.writeln('}');
    code.writeln('');
    code.writeln('class _${className}Columns {');
    for (var column in columns) {
      code.writeln(
          "final ${column.name.words.toLowerCamel()} = Column<$className>('${column.name}');");
    }
    code.writeln(
        'late final list = [${columns.map((c) => c.name.words.toLowerCamel()).join(', ')}];');
    code.writeln('}');

    return '$code';
  }

  String generateEnum(
      ConfiguredTable configuredTable, EnumDefinition enumDefinition) {
    var table = configuredTable.table;
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
factory $className(String $valueField) => 
   values.firstWhere((e) => e.$valueField == $valueField);
    
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

  Future<String> generateCrudFile(
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
    for (var configuredTable in tables) {
      var table = configuredTable.table;
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

  String generateCrudForTable(ConfiguredTable configuredTable) {
    var table = configuredTable.table;
    var code = StringBuffer('');

    var className = '${table.name.words.toUpperCamel()}Crud';
    var columns = table.columns;
    var primaryKeys = columns.where((c) => c.isPrimaryKey).toList();

    code.writeln('''
class $className {
  final Database _database;

  $className(this._database);    
''');

    _findCode(code, configuredTable, primaryKeys, orNull: false);
    _findCode(code, configuredTable, primaryKeys, orNull: true);
    _insertCode(code, configuredTable);
    if (columns.where((c) => !c.isPrimaryKey).isNotEmpty) {
      _updateCode(code, configuredTable);
    }
    _deleteCode(code, configuredTable, primaryKeys);

    code.writeln('}');
    return '$code';
  }

  void _findCode(StringBuffer code, ConfiguredTable configuredTable,
      List<ColumnDefinition> primaryKeys,
      {required bool orNull}) {
    var table = configuredTable.table;

    var entityName = table.name.words.toUpperCamel();

    code.writeln(
        'Future<$entityName${orNull ? '?' : ''}> find${orNull ? 'OrNull' : ''}'
        '(${primaryKeys.map((p) => '${p.type.dartType} ${p.name.words.toLowerCamel()}').join(', ')}) {');
    code.writeln('return _database.single${orNull ? 'OrNull' : ''}(');
    code.writeln('  //language=sql');

    var where = primaryKeys
        .map((p) =>
            '${p.name} = :${p.name.words.toLowerCamel()}::${p.type.postgresType}')
        .join(' and ');
    code.writeln("'select * from ${table.name} where $where',");
    code.writeln('  //language=none');
    code.writeln('args: {');
    for (var p in primaryKeys) {
      code.writeln(
          "'${p.name.words.toLowerCamel()}': ${p.name.words.toLowerCamel()},");
    }
    code.writeln('},');
    code.writeln('mapper: $entityName.fromRow,');
    code.writeln(');');
    code.writeln('}');
    code.writeln('');
  }

  void _insertCode(StringBuffer code, ConfiguredTable configuredTable) {
    var table = configuredTable.table;
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

  void _updateCode(StringBuffer code, ConfiguredTable configuredTable) {
    var table = configuredTable.table;
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

    var primaryKeys = table.columns.where((c) => c.isPrimaryKey).toList();
    var skipPrimaryInEntity = configuredTable.config.skipPrimaryInEntity;
    var prefix = '';
    if (skipPrimaryInEntity) {
      prefix = primaryKeys
          .map((c) => '${c.type.dartType} ${c.name.words.toLowerCamel()}')
          .join(', ');
      prefix += ',';
    }

    code.writeln(
        'Future<$entityName> updateEntity($prefix$entityName entity) {');
    code.writeln('return update(');
    for (var primaryKey in primaryKeys) {
      var prefix = 'entity.';
      if (skipPrimaryInEntity) {
        prefix = '';
      }
      code.write('$prefix${primaryKey.name.words.toLowerCamel()},');
    }
    for (var column in table.columns.where((c) => !c.isPrimaryKey)) {
      var enumRef =
          enums.firstWhereOrNull((e) => e.table.name == column.reference);
      var enumSuffix = '';
      if (enumRef != null) {
        enumSuffix =
            '${column.isNullable ? '?' : ''}.${enumRef.primaryKey.name.words.toLowerCamel()}';
      }
      var fieldName = column.name.words.toLowerCamel();
      code.write('$fieldName: entity.$fieldName$enumSuffix,');
      if (column.isNullable) {
        code.write(
            'clear${column.name.words.toUpperCamel()}: entity.$fieldName == null,');
      }
    }
    code.writeln(');');
    code.writeln('}');

    code.writeln('');
  }

  void _deleteCode(StringBuffer code, ConfiguredTable configuredTable,
      List<ColumnDefinition> primaryKeys) {
    var table = configuredTable.table;
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
      code.writeln(
          "'${p.name.words.toLowerCamel()}': ${p.name.words.toLowerCamel()},");
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

class _ColumnField {
  final ColumnDefinition column;
  final EnumDefinition? reference;
  final String _name;

  _ColumnField(this.column, {this.reference})
      : _name = column.name.words.toLowerCamel();

  String get name => _name;

  bool get isNullable => column.isNullable;

  String get type {
    return reference?.table.name.words.toUpperCamel() ?? column.type.dartType;
  }

  ValueType get jsonType {
    var reference = this.reference;
    if (reference == null) {
      return ValueType.fromTypeName(type, isNullable: isNullable);
    } else {
      return ComplexType(reference.table.name.words.toUpperCamel(),
          isNullable: isNullable);
    }
  }
}
