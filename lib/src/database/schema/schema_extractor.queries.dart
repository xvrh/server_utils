// GENERATED-CODE: do not edit
// Code is generated from schema_extractor.queries.sql

import 'package:server_utils/database.dart';

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

  Future<List<Column>> columnsForSchema({String schemaName = 'public'}) {
    return Query<Column>(
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
      mapper: Column.fromRow,
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
    return Query(
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
}

class Column {
  final String tableName;
  final String columnName;
  final String? columnDefault;
  final String dataType;
  final int? characterMaximumLength;
  final String? domainName;
  final bool isNullable;

  Column({
    required this.tableName,
    required this.columnName,
    this.columnDefault,
    required this.dataType,
    this.characterMaximumLength,
    this.domainName,
    required this.isNullable,
  });

  factory Column.fromRow(Map<String, dynamic> row) {
    return Column(
      tableName: row['table_name']! as String,
      columnName: row['column_name']! as String,
      columnDefault: row['column_default'] as String?,
      dataType: row['data_type']! as String,
      characterMaximumLength: row['character_maximum_length'] as int?,
      domainName: row['domain_name'] as String?,
      isNullable: row['is_nullable']! as bool,
    );
  }

  factory Column.fromJson(Map<String, Object?> json) {
    return Column(
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
}

class PrimaryKey {
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
}

class ForeignKey {
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
}

class ColumnDescription {
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
}

class DomainDescription {
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
}
