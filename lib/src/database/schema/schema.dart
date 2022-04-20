import 'package:collection/collection.dart';
import '../../utils/escape_dart_string.dart';

class DatabaseSchema {
  static final empty = DatabaseSchema([], []);

  final List<TableDefinition> tables;
  final List<EnumDefinition> enums;

  DatabaseSchema(this.tables, this.enums);

  TableDefinition? operator [](String tableName) =>
      tables.firstWhereOrNull((e) => e.name == tableName);
}

class TableDefinition {
  final String name;
  final List<ColumnDefinition> columns;

  const TableDefinition(this.name, this.columns);

  ColumnDefinition? operator [](String columnName) =>
      columns.firstWhereOrNull((e) => e.name == columnName);

  @override
  String toString() => 'Table($name, columns: $columns)';
}

class ColumnDefinition {
  final int id;
  final DataType type;
  final String name;
  final String? domain;
  final bool isNullable, isPrimaryKey;
  final String? defaultValue;
  final String? foreignTable;
  final EnumDefinition? enumDefinition;

  const ColumnDefinition(
    this.id,
    this.name, {
    required this.type,
    bool? isNullable,
    bool? isPrimaryKey,
    this.defaultValue,
    this.domain,
    this.foreignTable,
    this.enumDefinition,
  })  : isNullable = isNullable ?? true,
        isPrimaryKey = isPrimaryKey ?? false;

  String toCode() {
    var domain = this.domain;
    var foreignTable = this.foreignTable;
    var enumDefinition = this.enumDefinition;
    var args = <String, String?>{
      'type': type.toCode(),
      if (domain != null) 'domain': escapeDartString(domain),
      if (!isNullable) 'isNullable': '$isNullable',
      if (isPrimaryKey) 'isPrimaryKey': '$isPrimaryKey',
      if (foreignTable != null) 'foreignTable': escapeDartString(foreignTable),
      if (enumDefinition != null) 'enumDefinition': enumDefinition.toCode(),
    };

    var argCode = args.entries.map((e) => '${e.key}: ${e.value}').join(',');
    return "ColumnDefinition($id, '$name', $argCode)";
  }

  @override
  String toString() => name;
}

class EnumDefinition {
  final String name;
  final List<String> values;
  final int typeId;

  const EnumDefinition(this.name, this.values, {required this.typeId});

  String toCode() {
    return "EnumDefinition('$name', [${values.map((v) => escapeDartString(v)).join(',')}], typeId: 0)";
  }
}

// When adding a datatype, make sure to add it in data_type_postgres file.
// This file reference dart:io which cannot be used here.
class DataType<T> {
  static const integer = DataType<int>._(
    'integer',
    'integer',
    'int4',
    aliases: ['int', 'int4'],
    dartType: 'int',
  );
  static const integerArray = DataType<List<int>>._(
    'integerArray',
    'integer[]',
    '_int4',
    aliases: ['int[]', 'int4[]'],
    dartType: 'List<int>',
  );
  static const bigint = DataType<int>._(
    'bigint',
    'bigint',
    'int8',
    aliases: ['int8'],
    dartType: 'int',
  );
  static const smallint = DataType<int>._(
    'smallint',
    'smallint',
    'int2',
    aliases: ['int2'],
    dartType: 'int',
  );
  static const serial = DataType<int>._(
    'serial',
    'serial',
    'int4',
    aliases: ['serial4'],
    dartType: 'int',
  );
  static const bigserial = DataType<int>._(
    'bigserial',
    'bigserial',
    'int8',
    aliases: ['serial8'],
    dartType: 'int',
  );
  static const text = DataType<String>._(
    'text',
    'text',
    'text',
    dartType: 'String',
  );
  static const name = DataType<String>._(
    'name',
    'name',
    'name',
    dartType: 'String',
  );
  static const textArray = DataType<List<String>>._(
    'textArray',
    'text[]',
    '_text',
    dartType: 'List<String>',
  );
  static const character = DataType<String>._(
    'character',
    'character',
    'text',
    aliases: ['har'],
    dartType: 'String',
  );
  static const characterVarying = DataType<String>._(
    'characterVarying',
    'character varying',
    'varchar',
    aliases: ['varchar'],
    dartType: 'String',
  );
  static const real = DataType<double>._(
    'real',
    'real',
    'float4',
    aliases: ['float4'],
    dartType: 'double',
  );
  static const doublePrecision = DataType<double>._(
    'doublePrecision',
    'double precision',
    'float8',
    aliases: ['float8'],
    dartType: 'double',
  );
  static const doubleArray = DataType<List<double>>._(
    'doubleArray',
    'float8[]',
    '_float8',
    dartType: 'List<double>',
  );
  static const boolean = DataType<bool>._(
    'boolean',
    'boolean',
    'boolean',
    aliases: ['bool'],
    dartType: 'bool',
  );
  static const timestampWithTimeZone = DataType<DateTime>._(
    'timestampWithTimeZone',
    'timestamp with time zone',
    'timestamptz',
    aliases: ['timestamptz'],
    dartType: 'DateTime',
  );
  static const timestampWithoutTimeZone = DataType<DateTime>._(
    'timestampWithoutTimeZone',
    'timestamp without time zone',
    'timestamp',
    aliases: ['timestamp'],
    dartType: 'DateTime',
  );
  static const date = DataType<DateTime>._(
    'date',
    'date',
    'date',
    dartType: 'DateTime',
  );
  static const json = DataType<dynamic>._(
    'json',
    'json',
    'json',
    dartType: 'Object',
  );
  static const jsonb = DataType<dynamic>._(
    'jsonb',
    'jsonb',
    'jsonb',
    dartType: 'Object',
  );
  static const jsonbArray = DataType<List<dynamic>>._(
    'jsonbArray',
    'jsonb[]',
    '_jsonb',
    dartType: 'List<dynamic>',
  );
  static const bytea = DataType<List<int>>._(
    'bytea',
    'bytea',
    'bytea',
    dartType: 'List<int>',
  );
  static const uuid = DataType<String>._(
    'uuid',
    'uuid',
    'uuid',
    dartType: 'String',
  );

  static final _all = <DataType>{
    integer,
    integerArray,
    bigint,
    smallint,
    serial,
    bigserial,
    text,
    name,
    textArray,
    character,
    characterVarying,
    real,
    doublePrecision,
    doubleArray,
    boolean,
    timestampWithTimeZone,
    timestampWithoutTimeZone,
    date,
    json,
    jsonb,
    jsonbArray,
    bytea,
    uuid,
  };
  static final _allAndAliases = <String, DataType>{
    for (var type in _all) type.postgresType: type,
    for (var type in _all)
      for (var alias in type.aliases) alias: type,
  };

  static DataType fromPostgresName(String name) {
    var type = tryPostgresName(name);
    if (type == null) {
      throw UnsupportedError(
          'Type [$name] not found. Add it to the list of supported type.');
    }
    return type;
  }

  static DataType? tryPostgresName(String name) {
    return _allAndAliases[name.toLowerCase()];
  }

  final String postgresType;
  final List<String> aliases;
  final String dartType;
  final String code;

  // TypeString from postgres library
  final String typeString;

  const DataType._(this.code, this.postgresType, this.typeString,
      {List<String>? aliases, required this.dartType})
      : aliases = aliases ?? const [];

  Type get type => T;

  String toCode() => 'DataType.$code';

  @override
  String toString() => postgresType;
}
