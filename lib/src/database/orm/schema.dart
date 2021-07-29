abstract class TableDefinition {
  String get name;

  ColumnDefinitions get columns;

  List<ColumnDefinition> get columnList;
}

abstract class ColumnDefinitions {}

class ColumnDefinition<TField> {
  final DataType<TField> type;
  final String name;
  final bool isNullable, isPrimaryKey;
  final String? defaultValue;

  const ColumnDefinition(this.name,
      {required this.type,
      bool? isNullable,
      bool? isPrimaryKey,
      this.defaultValue})
      : isNullable = isNullable ?? true,
        isPrimaryKey = isPrimaryKey ?? false;

  static ColumnDefinition forType(String typeName, String name,
      {bool? isNullable, bool? isPrimaryKey, String? defaultValue}) {
    var type = DataType.fromPostgresName(typeName);
    if (type is DataType<int>) {
      return ColumnDefinition<int>(name,
          type: type,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    } else if (type is DataType<double>) {
      return ColumnDefinition<double>(name,
          type: type,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    } else if (type is DataType<String>) {
      return ColumnDefinition<String>(name,
          type: type,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    } else if (type is DataType<bool>) {
      return ColumnDefinition<bool>(name,
          type: type,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    } else if (type is DataType<DateTime>) {
      return ColumnDefinition<DateTime>(name,
          type: type,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    } else {
      return ColumnDefinition<dynamic>(name,
          type: type,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    }
  }

  Type get dartType => type.type;

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
  static const textArray = DataType<List<String>>._(
    'text[]',
    dartType: 'List<String>',
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
    dartType: 'dynamic',
  );
  static const jsonb = DataType<dynamic>._(
    'jsonb',
    dartType: 'dynamic',
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

  final String postgresType;
  final List<String> aliases;
  final String dartType;

  const DataType._(this.postgresType,
      {List<String>? aliases, required this.dartType})
      : aliases = aliases ?? const [];

  Type get type => T;

  static final _all = <DataType>{
    integer,
    integerArray,
    bigint,
    smallint,
    serial,
    bigserial,
    text,
    textArray,
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
          'Type $name not found. Add it to the list of supported type.');
    }
    return type;
  }

  @override
  String toString() => postgresType;
}
