// GENERATED-CODE: do not edit
// Code is generated from schema.queries.sql
import 'package:server_utils/database.dart';

extension SchemaQueries on Database {
  Query<String> tablesForSchema({
    required String schemaName,
  }) {
    return Query<String>.singleColumn(this,
        //language=sql
        r'''
select table_name::text /*nullable=false*/
from information_schema.tables
where table_schema = :schemaName::text /*default='public'*/;
''', arguments: {
      'schemaName': schemaName,
    });
  }

  Query<Column> columnsForSchema({
    required String schemaName,
  }) {
    return Query<Column>(
      this,
      //language=sql
      r'''
select table_name /*nullable=false*/,
       column_name /*nullable=false*/,
       column_default,
       data_type /*nullable=false*/,
       character_maximum_length,
       case
           when is_nullable = 'YES' then true
           else false
           end as is_nullable /*nullable=false*/
from information_schema.columns
where table_schema = :schemaName::text/*default='public'*/;
''',
      arguments: {
        'schemaName': schemaName,
      },
      mapper: Column.fromRow,
    );
  }

  Query<Constraint> constraintsForSchema({
    required String schemaName,
  }) {
    return Query<Constraint>(
      this,
      //language=sql
      r'''
-- columns: nullable=false
select t.table_catalog,
       t.table_name,
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
where t.table_schema = :schemaName::text/*default='public'*/
order by t.table_catalog,
         t.table_name,
         kcu.constraint_name,
         kcu.ordinal_position;
''',
      arguments: {
        'schemaName': schemaName,
      },
      mapper: Constraint.fromRow,
    );
  }

  Future<List<Table>> describeTable({
    required String schemaName,
    required String tableName,
  }) {
    return Query<Table>(
      this,
      //language=sql
      r'''
select f.attnum                                        as number/*nullable=false*/,
       f.attname                                       as name,
       f.attnum,
       f.attnotnull                                    as "not_null"/*nullable=false*/,
       f.atttypid::int                                 as type_id/*nullable=false*/,
       pg_catalog.format_type(f.atttypid, f.atttypmod) as type/*nullable=false*/,
       case
           when p.contype = 'p' then true
           else false
           end                                         as primary_key /*nullable=false*/,
       case
           when p.contype = 'u' then true
           else false
           end                                         as unique_key/*nullable=false*/,
       case
           when p.contype = 'f' then g.relname
           end                                         as foreign_key/*nullable=false*/,
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
  and c.relname = :tableName::text
  and f.attnum > 0
order by number
''',
      arguments: {
        'schemaName': schemaName,
        'tableName': tableName,
      },
      mapper: Table.fromRow,
    ).list;
  }
}

class Column {
  final String tableName;
  final String columnName;
  final String? columnDefault;
  final String dataType;
  final int? characterMaximumLength;
  final bool isNullable;

  Column({
    required this.tableName,
    required this.columnName,
    this.columnDefault,
    required this.dataType,
    this.characterMaximumLength,
    required this.isNullable,
  });

  static Column fromRow(Map<String, dynamic> row) {
    return Column(
      tableName: row['table_name']! as String,
      columnName: row['column_name']! as String,
      columnDefault: row['column_default'] as String?,
      dataType: row['data_type']! as String,
      characterMaximumLength: row['character_maximum_length'] as int?,
      isNullable: row['is_nullable']! as bool,
    );
  }
}

class Constraint {
  final String tableCatalog;
  final String tableName;
  final String constraintName;
  final String columnName;
  final int ordinalPosition;

  Constraint({
    required this.tableCatalog,
    required this.tableName,
    required this.constraintName,
    required this.columnName,
    required this.ordinalPosition,
  });

  static Constraint fromRow(Map<String, dynamic> row) {
    return Constraint(
      tableCatalog: row['table_catalog']! as String,
      tableName: row['table_name']! as String,
      constraintName: row['constraint_name']! as String,
      columnName: row['column_name']! as String,
      ordinalPosition: row['ordinal_position']! as int,
    );
  }
}

class Table {
  final int number;
  final String? name;
  final int? attnum;
  final bool notNull;
  final int typeId;
  final String type;
  final bool primaryKey;
  final bool uniqueKey;
  final String foreignKey;
  final List<int>? foreignKeyFieldnum;
  final String? defaultInfo;

  Table({
    required this.number,
    this.name,
    this.attnum,
    required this.notNull,
    required this.typeId,
    required this.type,
    required this.primaryKey,
    required this.uniqueKey,
    required this.foreignKey,
    this.foreignKeyFieldnum,
    this.defaultInfo,
  });

  static Table fromRow(Map<String, dynamic> row) {
    return Table(
      number: row['number']! as int,
      name: row['name'] as String?,
      attnum: row['attnum'] as int?,
      notNull: row['not_null']! as bool,
      typeId: row['type_id']! as int,
      type: row['type']! as String,
      primaryKey: row['primary_key']! as bool,
      uniqueKey: row['unique_key']! as bool,
      foreignKey: row['foreign_key']! as String,
      foreignKeyFieldnum: row['foreign_key_fieldnum'] as List<int>?,
      defaultInfo: row['default_info'] as String?,
    );
  }
}
