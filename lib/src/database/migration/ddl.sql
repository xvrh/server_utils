
create table _migration_history (
    id serial primary key,
    name text not null,
    date timestamptz not null default now()
);
