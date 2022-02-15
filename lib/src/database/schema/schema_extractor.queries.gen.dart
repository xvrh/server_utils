// GENERATED-CODE: do not edit
// Code is generated from schema_extractor.queries.dart

part of 'schema_extractor.queries.dart';

extension SchemaExtractorQueries on Database {
  Future<List<String>> tablesForSchema({String schemaName = 'public'}) {
    return Query<String>.singleColumn(this,
        //language=sql
        r'''
select table_name::text
from information_schema.tables
where table_schema = :schemaName::text
''', arguments: {
      'schemaName': schemaName,
    }).list;
  }

  Future<List<ColumnData>> columnsForSchema({String schemaName = 'public'}) {
    return Query<ColumnData>(
      this,
      //language=sql
      r'''
select table_name,
       column_name,
       column_default,
       data_type,
       character_maximum_length,
       domain_name,
       case
           when is_nullable = 'YES' then true
           else false
           end as is_nullable
from information_schema.columns
where table_schema = :schemaName::text
order by ordinal_position
''',
      arguments: {
        'schemaName': schemaName,
      },
      mapper: ColumnData.fromRow,
    ).list;
  }

  Future<List<PrimaryKey>> primaryKeysForSchema(
      {String schemaName = 'public'}) {
    return Query<PrimaryKey>(
      this,
      //language=sql
      r'''
select t.table_name,
       kcu.constraint_name,
       kcu.column_name,
       kcu.ordinal_position
from information_schema.tables t
         left join information_schema.table_constraints tc
                   on tc.table_catalog = t.table_catalog
                       and tc.table_schema = t.table_schema
                       and tc.table_name = t.table_name
                       and tc.constraint_type = 'PRIMARY KEY'
         left join information_schema.key_column_usage kcu
                   on kcu.table_catalog = tc.table_catalog
                       and kcu.table_schema = tc.table_schema
                       and kcu.table_name = tc.table_name
                       and kcu.constraint_name = tc.constraint_name
where t.table_schema = :schemaName::text
order by t.table_catalog,
         t.table_name,
         kcu.constraint_name,
         kcu.ordinal_position
''',
      arguments: {
        'schemaName': schemaName,
      },
      mapper: PrimaryKey.fromRow,
    ).list;
  }

  Future<List<ForeignKey>> foreignKeysForSchema(
      {String schemaName = 'public'}) {
    return Query<ForeignKey>(
      this,
      //language=sql
      r'''
SELECT
    tc.table_schema,
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM
    information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
             ON tc.constraint_name = kcu.constraint_name
                 AND tc.table_schema = kcu.table_schema
        JOIN information_schema.constraint_column_usage AS ccu
             ON ccu.constraint_name = tc.constraint_name
                 AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = :schemaName
''',
      arguments: {
        'schemaName': schemaName,
      },
      mapper: ForeignKey.fromRow,
    ).list;
  }

  Future<List<ColumnDescription>> describeTables(
      {String schemaName = 'public'}) {
    return Query<ColumnDescription>(
      this,
      //language=sql
      r'''
select c.relname::text                                 as table_name,
       f.attnum                                        as number,
       f.attname                                       as name,
       f.attnum,
       f.attnotnull                                    as "not_null",
       f.atttypid::int                                 as type_id,
       pg_catalog.format_type(f.atttypid, f.atttypmod) as type,
       case
           when p.contype = 'p' then true
           else false
           end                                         as is_primary_key,
       case
           when p.contype = 'u' then true
           else false
           end                                         as unique_key,
       case
           when p.contype = 'f' then g.relname
           end                                         as foreign_key,
       case
           when p.contype = 'f' then p.confkey::int4[]
           end                                         as foreign_key_fieldnum,
       case
           when f.atthasdef = 't' then pg_get_expr(d.adbin, d.adrelid)
           end                                         as "default_info"
from pg_attribute f
         join pg_class c on c.oid = f.attrelid
         join pg_type t on t.oid = f.atttypid
         left join pg_attrdef d on d.adrelid = c.oid and d.adnum = f.attnum
         left join pg_namespace n on n.oid = c.relnamespace
         left join pg_constraint p on p.conrelid = c.oid and f.attnum = any (p.conkey)
         left join pg_class as g on p.confrelid = g.oid
where c.relkind = 'r'::char
  and n.nspname = :schemaName::text
  and f.attnum > 0
order by table_name, number
''',
      arguments: {
        'schemaName': schemaName,
      },
      mapper: ColumnDescription.fromRow,
    ).list;
  }

  Future<List<DomainDescription>> domainsForSchema(
      {String schemaName = 'public'}) {
    return Query<DomainDescription>(
      this,
      //language=sql
      r'''
select pg_type.oid::int, typname as "name", typnotnull as "not_null", typdefault as "default_value"
from pg_catalog.pg_type
         join pg_catalog.pg_namespace on pg_namespace.oid = pg_type.typnamespace
where typtype = 'd'
  and nspname = :schemaName::text
''',
      arguments: {
        'schemaName': schemaName,
      },
      mapper: DomainDescription.fromRow,
    ).list;
  }

  // ignore: unused_element
  void _simulateUseElements() {
    print(_SchemaExtractorQueries(this).tablesForSchema);
    print(_SchemaExtractorQueries(this).columnsForSchema);
    print(_SchemaExtractorQueries(this).primaryKeysForSchema);
    print(_SchemaExtractorQueries(this).foreignKeysForSchema);
    print(_SchemaExtractorQueries(this).describeTables);
    print(_SchemaExtractorQueries(this).domainsForSchema);
  }
}

class ColumnData {
  static final columns = _ColumnDataColumns();

  final String tableName;
  final String columnName;
  final String? columnDefault;
  final String dataType;
  final int? characterMaximumLength;
  final String? domainName;
  final bool isNullable;

  ColumnData({
    required this.tableName,
    required this.columnName,
    this.columnDefault,
    required this.dataType,
    this.characterMaximumLength,
    this.domainName,
    required this.isNullable,
  });

  factory ColumnData.fromRow(Map<String, dynamic> row) {
    return ColumnData(
      tableName: row['table_name']! as String,
      columnName: row['column_name']! as String,
      columnDefault: row['column_default'] as String?,
      dataType: row['data_type']! as String,
      characterMaximumLength: row['character_maximum_length'] as int?,
      domainName: row['domain_name'] as String?,
      isNullable: row['is_nullable']! as bool,
    );
  }

  factory ColumnData.fromJson(Map<String, Object?> json) {
    return ColumnData(
      tableName: json['tableName']! as String,
      columnName: json['columnName']! as String,
      columnDefault: json['columnDefault'] as String?,
      dataType: json['dataType']! as String,
      characterMaximumLength: (json['characterMaximumLength'] as num?)?.toInt(),
      domainName: json['domainName'] as String?,
      isNullable: json['isNullable']! as bool,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'tableName': tableName,
      'columnName': columnName,
      'columnDefault': columnDefault,
      'dataType': dataType,
      'characterMaximumLength': characterMaximumLength,
      'domainName': domainName,
      'isNullable': isNullable,
    };
  }

  ColumnData copyWith({
    String? tableName,
    String? columnName,
    String? columnDefault,
    bool? clearColumnDefault,
    String? dataType,
    int? characterMaximumLength,
    bool? clearCharacterMaximumLength,
    String? domainName,
    bool? clearDomainName,
    bool? isNullable,
  }) {
    return ColumnData(
      tableName: tableName ?? this.tableName,
      columnName: columnName ?? this.columnName,
      columnDefault: (clearColumnDefault ?? false)
          ? null
          : columnDefault ?? this.columnDefault,
      dataType: dataType ?? this.dataType,
      characterMaximumLength: (clearCharacterMaximumLength ?? false)
          ? null
          : characterMaximumLength ?? this.characterMaximumLength,
      domainName:
          (clearDomainName ?? false) ? null : domainName ?? this.domainName,
      isNullable: isNullable ?? this.isNullable,
    );
  }
}

class _ColumnDataColumns {
  final tableName = Column<ColumnData>('table_name');
  final columnName = Column<ColumnData>('column_name');
  final columnDefault = Column<ColumnData>('column_default');
  final dataType = Column<ColumnData>('data_type');
  final characterMaximumLength = Column<ColumnData>('character_maximum_length');
  final domainName = Column<ColumnData>('domain_name');
  final isNullable = Column<ColumnData>('is_nullable');
  late final list = [
    tableName,
    columnName,
    columnDefault,
    dataType,
    characterMaximumLength,
    domainName,
    isNullable
  ];
}

class PrimaryKey {
  static final columns = _PrimaryKeyColumns();

  final String tableName;
  final String? constraintName;
  final String? columnName;
  final int? ordinalPosition;

  PrimaryKey({
    required this.tableName,
    this.constraintName,
    this.columnName,
    this.ordinalPosition,
  });

  factory PrimaryKey.fromRow(Map<String, dynamic> row) {
    return PrimaryKey(
      tableName: row['table_name']! as String,
      constraintName: row['constraint_name'] as String?,
      columnName: row['column_name'] as String?,
      ordinalPosition: row['ordinal_position'] as int?,
    );
  }

  factory PrimaryKey.fromJson(Map<String, Object?> json) {
    return PrimaryKey(
      tableName: json['tableName']! as String,
      constraintName: json['constraintName'] as String?,
      columnName: json['columnName'] as String?,
      ordinalPosition: (json['ordinalPosition'] as num?)?.toInt(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'tableName': tableName,
      'constraintName': constraintName,
      'columnName': columnName,
      'ordinalPosition': ordinalPosition,
    };
  }

  PrimaryKey copyWith({
    String? tableName,
    String? constraintName,
    bool? clearConstraintName,
    String? columnName,
    bool? clearColumnName,
    int? ordinalPosition,
    bool? clearOrdinalPosition,
  }) {
    return PrimaryKey(
      tableName: tableName ?? this.tableName,
      constraintName: (clearConstraintName ?? false)
          ? null
          : constraintName ?? this.constraintName,
      columnName:
          (clearColumnName ?? false) ? null : columnName ?? this.columnName,
      ordinalPosition: (clearOrdinalPosition ?? false)
          ? null
          : ordinalPosition ?? this.ordinalPosition,
    );
  }
}

class _PrimaryKeyColumns {
  final tableName = Column<PrimaryKey>('table_name');
  final constraintName = Column<PrimaryKey>('constraint_name');
  final columnName = Column<PrimaryKey>('column_name');
  final ordinalPosition = Column<PrimaryKey>('ordinal_position');
  late final list = [tableName, constraintName, columnName, ordinalPosition];
}

class ForeignKey {
  static final columns = _ForeignKeyColumns();

  final String tableSchema;
  final String constraintName;
  final String tableName;
  final String columnName;
  final String foreignTableSchema;
  final String foreignTableName;
  final String foreignColumnName;

  ForeignKey({
    required this.tableSchema,
    required this.constraintName,
    required this.tableName,
    required this.columnName,
    required this.foreignTableSchema,
    required this.foreignTableName,
    required this.foreignColumnName,
  });

  factory ForeignKey.fromRow(Map<String, dynamic> row) {
    return ForeignKey(
      tableSchema: row['table_schema']! as String,
      constraintName: row['constraint_name']! as String,
      tableName: row['table_name']! as String,
      columnName: row['column_name']! as String,
      foreignTableSchema: row['foreign_table_schema']! as String,
      foreignTableName: row['foreign_table_name']! as String,
      foreignColumnName: row['foreign_column_name']! as String,
    );
  }

  factory ForeignKey.fromJson(Map<String, Object?> json) {
    return ForeignKey(
      tableSchema: json['tableSchema']! as String,
      constraintName: json['constraintName']! as String,
      tableName: json['tableName']! as String,
      columnName: json['columnName']! as String,
      foreignTableSchema: json['foreignTableSchema']! as String,
      foreignTableName: json['foreignTableName']! as String,
      foreignColumnName: json['foreignColumnName']! as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'tableSchema': tableSchema,
      'constraintName': constraintName,
      'tableName': tableName,
      'columnName': columnName,
      'foreignTableSchema': foreignTableSchema,
      'foreignTableName': foreignTableName,
      'foreignColumnName': foreignColumnName,
    };
  }

  ForeignKey copyWith({
    String? tableSchema,
    String? constraintName,
    String? tableName,
    String? columnName,
    String? foreignTableSchema,
    String? foreignTableName,
    String? foreignColumnName,
  }) {
    return ForeignKey(
      tableSchema: tableSchema ?? this.tableSchema,
      constraintName: constraintName ?? this.constraintName,
      tableName: tableName ?? this.tableName,
      columnName: columnName ?? this.columnName,
      foreignTableSchema: foreignTableSchema ?? this.foreignTableSchema,
      foreignTableName: foreignTableName ?? this.foreignTableName,
      foreignColumnName: foreignColumnName ?? this.foreignColumnName,
    );
  }
}

class _ForeignKeyColumns {
  final tableSchema = Column<ForeignKey>('table_schema');
  final constraintName = Column<ForeignKey>('constraint_name');
  final tableName = Column<ForeignKey>('table_name');
  final columnName = Column<ForeignKey>('column_name');
  final foreignTableSchema = Column<ForeignKey>('foreign_table_schema');
  final foreignTableName = Column<ForeignKey>('foreign_table_name');
  final foreignColumnName = Column<ForeignKey>('foreign_column_name');
  late final list = [
    tableSchema,
    constraintName,
    tableName,
    columnName,
    foreignTableSchema,
    foreignTableName,
    foreignColumnName
  ];
}

class ColumnDescription {
  static final columns = _ColumnDescriptionColumns();

  final String tableName;
  final int number;
  final String name;
  final int attnum;
  final bool notNull;
  final int typeId;
  final String type;
  final bool isPrimaryKey;
  final bool uniqueKey;
  final String? foreignKey;
  final List<int>? foreignKeyFieldnum;
  final String? defaultInfo;

  ColumnDescription({
    required this.tableName,
    required this.number,
    required this.name,
    required this.attnum,
    required this.notNull,
    required this.typeId,
    required this.type,
    required this.isPrimaryKey,
    required this.uniqueKey,
    this.foreignKey,
    this.foreignKeyFieldnum,
    this.defaultInfo,
  });

  factory ColumnDescription.fromRow(Map<String, dynamic> row) {
    return ColumnDescription(
      tableName: row['table_name']! as String,
      number: row['number']! as int,
      name: row['name']! as String,
      attnum: row['attnum']! as int,
      notNull: row['not_null']! as bool,
      typeId: row['type_id']! as int,
      type: row['type']! as String,
      isPrimaryKey: row['is_primary_key']! as bool,
      uniqueKey: row['unique_key']! as bool,
      foreignKey: row['foreign_key'] as String?,
      foreignKeyFieldnum: row['foreign_key_fieldnum'] as List<int>?,
      defaultInfo: row['default_info'] as String?,
    );
  }

  factory ColumnDescription.fromJson(Map<String, Object?> json) {
    return ColumnDescription(
      tableName: json['tableName']! as String,
      number: (json['number']! as num).toInt(),
      name: json['name']! as String,
      attnum: (json['attnum']! as num).toInt(),
      notNull: json['notNull']! as bool,
      typeId: (json['typeId']! as num).toInt(),
      type: json['type']! as String,
      isPrimaryKey: json['isPrimaryKey']! as bool,
      uniqueKey: json['uniqueKey']! as bool,
      foreignKey: json['foreignKey'] as String?,
      foreignKeyFieldnum: (json['foreignKeyFieldnum'] as List<Object?>?)
          ?.map((i) => (i! as num).toInt())
          .toList(),
      defaultInfo: json['defaultInfo'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'tableName': tableName,
      'number': number,
      'name': name,
      'attnum': attnum,
      'notNull': notNull,
      'typeId': typeId,
      'type': type,
      'isPrimaryKey': isPrimaryKey,
      'uniqueKey': uniqueKey,
      'foreignKey': foreignKey,
      'foreignKeyFieldnum': foreignKeyFieldnum,
      'defaultInfo': defaultInfo,
    };
  }

  ColumnDescription copyWith({
    String? tableName,
    int? number,
    String? name,
    int? attnum,
    bool? notNull,
    int? typeId,
    String? type,
    bool? isPrimaryKey,
    bool? uniqueKey,
    String? foreignKey,
    bool? clearForeignKey,
    List<int>? foreignKeyFieldnum,
    bool? clearForeignKeyFieldnum,
    String? defaultInfo,
    bool? clearDefaultInfo,
  }) {
    return ColumnDescription(
      tableName: tableName ?? this.tableName,
      number: number ?? this.number,
      name: name ?? this.name,
      attnum: attnum ?? this.attnum,
      notNull: notNull ?? this.notNull,
      typeId: typeId ?? this.typeId,
      type: type ?? this.type,
      isPrimaryKey: isPrimaryKey ?? this.isPrimaryKey,
      uniqueKey: uniqueKey ?? this.uniqueKey,
      foreignKey:
          (clearForeignKey ?? false) ? null : foreignKey ?? this.foreignKey,
      foreignKeyFieldnum: (clearForeignKeyFieldnum ?? false)
          ? null
          : foreignKeyFieldnum ?? this.foreignKeyFieldnum,
      defaultInfo:
          (clearDefaultInfo ?? false) ? null : defaultInfo ?? this.defaultInfo,
    );
  }
}

class _ColumnDescriptionColumns {
  final tableName = Column<ColumnDescription>('table_name');
  final number = Column<ColumnDescription>('number');
  final name = Column<ColumnDescription>('name');
  final attnum = Column<ColumnDescription>('attnum');
  final notNull = Column<ColumnDescription>('not_null');
  final typeId = Column<ColumnDescription>('type_id');
  final type = Column<ColumnDescription>('type');
  final isPrimaryKey = Column<ColumnDescription>('is_primary_key');
  final uniqueKey = Column<ColumnDescription>('unique_key');
  final foreignKey = Column<ColumnDescription>('foreign_key');
  final foreignKeyFieldnum = Column<ColumnDescription>('foreign_key_fieldnum');
  final defaultInfo = Column<ColumnDescription>('default_info');
  late final list = [
    tableName,
    number,
    name,
    attnum,
    notNull,
    typeId,
    type,
    isPrimaryKey,
    uniqueKey,
    foreignKey,
    foreignKeyFieldnum,
    defaultInfo
  ];
}

class DomainDescription {
  static final columns = _DomainDescriptionColumns();

  final int oid;
  final String name;
  final bool notNull;
  final String? defaultValue;

  DomainDescription({
    required this.oid,
    required this.name,
    required this.notNull,
    this.defaultValue,
  });

  factory DomainDescription.fromRow(Map<String, dynamic> row) {
    return DomainDescription(
      oid: row['oid']! as int,
      name: row['name']! as String,
      notNull: row['not_null']! as bool,
      defaultValue: row['default_value'] as String?,
    );
  }

  factory DomainDescription.fromJson(Map<String, Object?> json) {
    return DomainDescription(
      oid: (json['oid']! as num).toInt(),
      name: json['name']! as String,
      notNull: json['notNull']! as bool,
      defaultValue: json['defaultValue'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'oid': oid,
      'name': name,
      'notNull': notNull,
      'defaultValue': defaultValue,
    };
  }

  DomainDescription copyWith({
    int? oid,
    String? name,
    bool? notNull,
    String? defaultValue,
    bool? clearDefaultValue,
  }) {
    return DomainDescription(
      oid: oid ?? this.oid,
      name: name ?? this.name,
      notNull: notNull ?? this.notNull,
      defaultValue: (clearDefaultValue ?? false)
          ? null
          : defaultValue ?? this.defaultValue,
    );
  }
}

class _DomainDescriptionColumns {
  final oid = Column<DomainDescription>('oid');
  final name = Column<DomainDescription>('name');
  final notNull = Column<DomainDescription>('not_null');
  final defaultValue = Column<DomainDescription>('default_value');
  late final list = [oid, name, notNull, defaultValue];
}
