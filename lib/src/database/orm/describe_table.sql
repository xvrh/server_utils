--# describeTable -> List<>
select
    f.attnum as number,
    f.attname as name,
    f.attnum,
    f.attnotnull as "notnull",
    pg_catalog.format_type(f.atttypid,f.atttypmod) as type,
    case
        when p.contype = 'p' then true
        else false
        end as primarykey,
    case
        when p.contype = 'u' then true
        else false
        end as uniquekey,
    case
        when p.contype = 'f' then g.relname
        end as foreignkey,
    case
        when p.contype = 'f' then p.confkey
        end as foreignkey_fieldnum,
    case
        when p.contype = 'f' then g.relname
        end as foreignkey,
    case
        when f.atthasdef = 't' then pg_get_expr(d.adbin, d.adrelid)
        end as "default"
from pg_attribute f
         join pg_class c on c.oid = f.attrelid
         join pg_type t on t.oid = f.atttypid
         left join pg_attrdef d on d.adrelid = c.oid and d.adnum = f.attnum
         left join pg_namespace n on n.oid = c.relnamespace
         left join pg_constraint p on p.conrelid = c.oid and f.attnum = any (p.conkey)
         left join pg_class as g on p.confrelid = g.oid
where c.relkind = 'r'::char
  and n.nspname = 'public'
  and c.relname = :tablename::text
  and f.attnum > 0 order by number