import 'package:collection/collection.dart';

class DatabaseSchema {
  static final empty = DatabaseSchema([]);

  final List<TableDefinition> tables;

  DatabaseSchema(this.tables);

  TableDefinition? operator [](String tableName) =>
      tables.firstWhereOrNull((e) => e.name == tableName);
}

class TableDefinition {
  final String name;
  final List<ColumnDefinition> columns;

  TableDefinition(this.name, this.columns);

  ColumnDefinition? operator [](String columnName) =>
      columns.firstWhereOrNull((e) => e.name == columnName);

  @override
  String toString() => 'Table($name, columns: $columns)';
}

class ColumnDefinition {
  final DataType type;
  final String name;
  final String? domain;
  final bool isNullable, isPrimaryKey;
  final String? defaultValue;

  const ColumnDefinition(
    this.name, {
    required this.type,
    bool? isNullable,
    bool? isPrimaryKey,
    this.defaultValue,
    this.domain,
  })  : isNullable = isNullable ?? true,
        isPrimaryKey = isPrimaryKey ?? false;

  @override
  String toString() => name;
}

// When adding a datatype, make sure to add it in data_type_postgres file.
// This file reference dart:io which cannot be used here.
class DataType<T> {
  static const integer = DataType<int>._(
    'integer',
    aliases: ['int', 'int4'],
    dartType: 'int',
  );
  static const integerArray = DataType<List<int>>._(
    'integer[]',
    aliases: ['int[]', 'int4[]'],
    dartType: 'List<int>',
  );
  static const bigint = DataType<int>._(
    'bigint',
    aliases: ['int8'],
    dartType: 'int',
  );
  static const smallint = DataType<int>._(
    'smallint',
    aliases: ['int2'],
    dartType: 'int',
  );
  static const serial = DataType<int>._(
    'serial',
    aliases: ['serial4'],
    dartType: 'int',
  );
  static const bigserial = DataType<int>._(
    'bigserial',
    aliases: ['serial8'],
    dartType: 'int',
  );
  static const text = DataType<String>._(
    'text',
    dartType: 'String',
  );
  static const name = DataType<String>._(
    'name',
    dartType: 'String',
  );
  static const textArray = DataType<List<String>>._(
    'text[]',
    dartType: 'List<String>',
  );
  static const character = DataType<String>._(
    'character',
    aliases: ['har'],
    dartType: 'String',
  );
  static const characterVarying = DataType<String>._(
    'character varying',
    aliases: ['varchar'],
    dartType: 'String',
  );
  static const real = DataType<double>._(
    'real',
    aliases: ['float4'],
    dartType: 'double',
  );
  static const doublePrecision = DataType<double>._(
    'double precision',
    aliases: ['float8'],
    dartType: 'double',
  );
  static const doubleArray = DataType<List<double>>._(
    'float8[]',
    dartType: 'List<double>',
  );
  static const boolean = DataType<bool>._(
    'boolean',
    aliases: ['bool'],
    dartType: 'bool',
  );
  static const timestampWithTimeZone = DataType<DateTime>._(
    'timestamp with time zone',
    aliases: ['timestamptz'],
    dartType: 'DateTime',
  );
  static const timestampWithoutTimeZone = DataType<DateTime>._(
    'timestamp without time zone',
    dartType: 'DateTime',
  );
  static const date = DataType<DateTime>._(
    'date',
    dartType: 'DateTime',
  );
  static const json = DataType<dynamic>._(
    'json',
    dartType: 'Object',
  );
  static const jsonb = DataType<dynamic>._(
    'jsonb',
    dartType: 'Object',
  );
  static const jsonbArray = DataType<List<dynamic>>._(
    'jsonb[]',
    dartType: 'List<dynamic>',
  );
  static const bytea = DataType<List<int>>._(
    'bytea',
    dartType: 'List<int>',
  );
  static const uuid = DataType<String>._(
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
    var type = _allAndAliases[name.toLowerCase()];
    if (type == null) {
      throw UnsupportedError(
          'Type [$name] not found. Add it to the list of supported type.');
    }
    return type;
  }

  final String postgresType;
  final List<String> aliases;
  final String dartType;

  const DataType._(this.postgresType,
      {List<String>? aliases, required this.dartType})
      : aliases = aliases ?? const [];

  Type get type => T;

  @override
  String toString() => postgresType;
}
