import 'package:server_utils/database.dart';

part 'schema_extractor.queries.gen.dart';

extension _SchemaExtractorQueries on Database {
  List<String> tablesForSchema({String schemaName = 'public'}) {
    //language=sql
    q(r'''
select table_name::text
from information_schema.tables
where table_schema = :schemaName::text
''');
  }

  List<ColumnData> columnsForSchema({String schemaName = 'public'}) {
    projection = {
      '*': Col(nullable: false),
      'column_default': Col(nullable: true),
      'character_maximum_length': Col(nullable: true),
      'domain_name': Col(nullable: true),
    };
    //language=sql
    q(r'''
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
''');
  }

  List<PrimaryKey> primaryKeysForSchema({String schemaName = 'public'}) {
    projection = {
      '*': Col(nullable: true),
      'table_name': Col(nullable: false),
    };
    //language=sql
    q(r'''
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
''');
  }

  List<ForeignKey> foreignKeysForSchema({String schemaName = 'public'}) {
    projection = {
      '*': Col(nullable: false),
    };
    q(
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
''');
  }

  List<ColumnDescription> describeTables({String schemaName = 'public'}) {
    projection = {
      '*': Col(nullable: false),
      'foreign_key': Col(nullable: true),
      'foreign_key_fieldnum': Col(nullable: true),
      'default_info': Col(nullable: true),
    };
    //language=sql

    q(r'''
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
''');
  }

  List<DomainDescription> domainsForSchema({String schemaName = 'public'}) {
    projection = {
      '*': Col(nullable: false),
      'default_value': Col(nullable: true),
    };
    //language=sql
    q(r'''
select pg_type.oid::int, typname as "name", typnotnull as "not_null", typdefault as "default_value"
from pg_catalog.pg_type
         join pg_catalog.pg_namespace on pg_namespace.oid = pg_type.typnamespace
where typtype = 'd'
  and nspname = :schemaName::text
''');
  }
}
