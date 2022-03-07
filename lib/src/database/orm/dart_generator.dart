import '../../utils/escape_dart_string.dart';
import '../../utils/quick_dart_formatter.dart';
import '../../utils/string.dart';
import '../../utils/type.dart';
import '../schema/schema.dart';

class ConfiguredSchema {
  static final empty = ConfiguredSchema(DatabaseSchema.empty, []);

  final DatabaseSchema schema;
  final List<ConfiguredTable> tables;

  ConfiguredSchema(this.schema, this.tables);
}

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
  ConfiguredSchema withConfig(Map<String, TableConfig> configs) {
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

    return ConfiguredSchema(this, configuredTables);
  }
}

class DomainConfig {
  final String dartType;
  final String rowConstructor;

  DomainConfig(this.dartType, {String? rowConstructor})
      : rowConstructor = '.fromJson';
}

class DartGenerator {
  final ConfiguredSchema schema;
  final Map<String, DomainConfig> domains;

  DartGenerator(this.schema, {Map<String, DomainConfig>? domains})
      : domains = domains ?? const {};

  DomainConfig? _domainForColumn(ColumnDefinition column) {
    var domainName = column.domain;
    if (domainName != null) {
      return domains[domainName];
    }
    return null;
  }

  List<_ColumnField> _computeFields(List<ColumnDefinition> columns) {
    var fields = <_ColumnField>[];
    for (var column in columns) {
      fields.add(_ColumnField(column, domain: _domainForColumn(column)));
    }
    return fields;
  }

  Future<String> generateEntities({List<String>? imports}) async {
    var code = StringBuffer('''
// GENERATED-FILE
import 'package:server_utils/database.dart';
''');

    for (var import in imports ?? const <String>[]) {
      code.writeln("import '$import';");
    }

    for (var enumDefinition in schema.schema.enums) {
      code.writeln(generateEnum(enumDefinition));
      code.writeln();
    }

    for (var configuredTable in schema.tables) {
      var table = configuredTable.table;

      var columns = table.columns.toList();
      if (configuredTable.config.skipPrimaryInEntity) {
        columns.removeWhere((e) => e.isPrimaryKey);
      }

      code.writeln(generateClassFromColumns(table.name, columns, table: table));
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

  String generateClassFromColumns(String name, List<ColumnDefinition> columns,
      {required TableDefinition? table}) {
    var code = StringBuffer('');

    var fields = _computeFields(columns);
    var className = name.words.toUpperCamel();

    code.writeln('class $className {');
    if (table != null) {
      code.writeln('static final table = TableDefinition(');
      code.write('${escapeDartString(table.name)},');
      code.write('[');
      for (var column in table.columns) {
        code.writeln('${column.toCode()},');
      }
      code.writeln('],);');
    }
    code.writeln('');
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
      var enumDefinition = field.column.enumDefinition;

      if (field.domain != null) {
        var fromJsonCode = field.jsonType.fromJsonCode(
            Value("row['${field.name}']", ObjectType(isNullable: true)));
        code.writeln('$fromJsonCode,');
      } else if (enumDefinition == null) {
        code.writeln(
            "row['${field.column.name}']${field.isNullable ? '' : '!'} "
            "as ${field.type}${field.isNullable ? '?' : ''},");
      } else {
        code.writeln('${enumDefinition.name.words.toUpperCamel()}'
            ".fromRow(row['${field.column.name}']${field.isNullable ? '' : '!'} as String),");
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
    code.writeln('}');

    return '$code';
  }

  String generateEnum(EnumDefinition enumDefinition) {
    var code = StringBuffer('');

    var className = enumDefinition.name.words.toUpperCamel();

    code.writeln('class $className implements EnumLike {');
    var index = 0;
    for (var enumLine in enumDefinition.values) {
      code.writeln(
          'static const ${enumLine.words.toLowerCamel()} = $className._(${escapeDartString(enumLine)}, $index);');
      ++index;
    }
    code.writeln('');
    code.writeln('static const values = [');
    for (var enumLine in enumDefinition.values) {
      code.writeln('${enumLine.words.toLowerCamel()},');
    }
    code.writeln('];');
    code.writeln('''
    
    @override
    final String value;
    
    @override
    final int index;
''');

    code.writeln('');
    code.writeln('const $className._(this.value, this.index);');
    code.writeln('');

    // Use static instead of factory so that the analyzer recognize the class
    // as an Enum-like class and trigger the warnings when switch cases are not complete
    code.writeln('''
static $className fromRow(String value) => 
   values.firstWhere((e) => e.value == value);

static $className fromJson(String json) =>
  values.firstWhere((e) => e.value == json,
    orElse: () => $className._(json, 0xffff));
    
String toJson() => value;

bool get isUnknown => values.every((v) => v.value != value);

@override
String toString() => value;
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
    for (var configuredTable in schema.tables) {
      var table = configuredTable.table;
      var className = '${table.name.words.toUpperCamel()}Crud';
      code.writeln(
          '$className get ${table.name.words.toLowerCamel()} => $className(this);');
      code.writeln();
    }
    code.writeln('}');

    for (var table in schema.tables) {
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

    var fields = _computeFields(table.columns);

    code.writeln('Future<$entityName> insert({');
    for (var field in fields) {
      var fieldName = field.name;
      if (field.isNullable || field.column.defaultValue != null) {
        var type = field.type;
        if (type == 'dynamic') {
          type = 'Object';
        }
        type += '?';
        var comment = '';
        if (field.column.defaultValue != null) {
          comment = '/* ${field.column.defaultValue} */';
        }
        code.writeln('$type $fieldName $comment,');
      } else {
        code.writeln('required ${field.type} $fieldName,');
      }
    }
    code.writeln('}) {');
    code.writeln("return _database.insert('${table.name}',");
    code.writeln('values: {');
    for (var field in fields) {
      var variableName = field.name;
      if (field.isNullable || field.column.defaultValue != null) {
        code.writeln('if ($variableName != null)');
      }
      if (field.domain != null) {
        variableName = '$variableName.toJson()';
      }
      var enumRef = field.column.enumDefinition;
      if (enumRef != null) {
        variableName = '$variableName.value';
      }
      code.writeln("'${field.column.name}': $variableName,");
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

    var fields = _computeFields(table.columns);

    code.write('Future<$entityName> update(');
    for (var primaryKey in fields.where((c) => c.column.isPrimaryKey)) {
      code.write('${primaryKey.type} ${primaryKey.name},');
    }
    code.write('{');
    var clears = <ColumnDefinition>[];
    for (var field in fields.where((c) => !c.column.isPrimaryKey)) {
      code.write('${field.type}? ${field.name},');
      if (field.isNullable) {
        clears.add(field.column);
        code.write('bool? clear${field.column.name.words.toUpperCamel()},');
      }
    }
    code.writeln('}) {');
    code.writeln('return _database.update($entityName.table,');
    code.writeln('where: {');
    for (var primaryKey in table.columns.where((c) => c.isPrimaryKey)) {
      code.write(
          "'${primaryKey.name}': ${primaryKey.name.words.toLowerCamel()},");
    }
    code.writeln('},');
    code.writeln('set: {');
    for (var column in table.columns.where((c) => !c.isPrimaryKey)) {
      var variable = column.name.words.toLowerCamel();
      var enumRef = column.enumDefinition;
      var suffix = '';
      if (enumRef != null) {
        suffix = '.value';
      }
      code.write("if ($variable != null) '${column.name}': $variable$suffix,");
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
      var fieldName = column.name.words.toLowerCamel();
      code.write('$fieldName: entity.$fieldName,');
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

class _ColumnField {
  final ColumnDefinition column;
  final DomainConfig? domain;
  final String _name;

  _ColumnField(this.column, {this.domain})
      : _name = column.name.words.toLowerCamel();

  String get name => _name;

  bool get isNullable => column.isNullable;

  String get type {
    var domain = this.domain;
    if (domain != null) {
      return domain.dartType;
    }
    var enumDefinition = column.enumDefinition;
    if (enumDefinition != null) {
      return enumDefinition.name.words.toUpperCamel();
    }
    return column.type.dartType;
  }

  ValueType get jsonType {
    var domain = this.domain;
    if (domain != null) {
      return ComplexType(domain.dartType, isNullable: isNullable);
    }
    var enumDefinition = column.enumDefinition;
    if (enumDefinition == null) {
      return ValueType.fromTypeName(type, isNullable: isNullable);
    } else {
      return EnumLikeType(type, isNullable: isNullable);
    }
  }
}
