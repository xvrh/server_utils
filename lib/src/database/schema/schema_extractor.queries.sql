/******************************
List<String> tablesForSchema({String schemaName = 'public'})
*******************************/
select table_name::text
from information_schema.tables
where table_schema = :schemaName::text;

/******************************
List<Column> columnsForSchema({String schemaName = 'public'})
projection Column (
  * not null,
  column_default null,
  character_maximum_length null,
  domain_name null,
)
*******************************/
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
order by ordinal_position;

/******************************
List<Constraint> constraintsForSchema({String schemaName = 'public'})
projection Constraint (
  * null,
  table_name not null
)
*******************************/
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
         kcu.ordinal_position;

/******************************
List<ColumnDescription> describeTable({String schemaName = 'public', required String tableName})
projection ColumnDescription (
  * not null,
  foreign_key null,
  foreign_key_fieldnum null,
  default_info null,
)
*******************************/
select f.attnum                                        as number,
       f.attname                                       as name,
       f.attnum,
       f.attnotnull                                    as "not_null",
       f.atttypid::int                                 as type_id,
       pg_catalog.format_type(f.atttypid, f.atttypmod) as type,
       case
           when p.contype = 'p' then true
           else false
           end                                         as primary_key,
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
  and c.relname = :tableName::text
  and f.attnum > 0
order by number;

/******************************
List<DomainDescription> domainsForSchema({String schemaName = 'public'})
projection DomainDescription (
  * not null,
  default_value null,
)
*******************************/
select pg_type.oid::int, typname as "name", typnotnull as "not_null", typdefault as "default_value"
from pg_catalog.pg_type
         join pg_catalog.pg_namespace on pg_namespace.oid = pg_type.typnamespace
where typtype = 'd'
  and nspname = :schemaName::text
