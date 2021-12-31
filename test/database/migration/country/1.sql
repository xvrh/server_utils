create table country
(
    id            serial primary key,
    code          varchar(2) not null unique,
    currency_rate real,
    name          jsonb,
    is_inEurope   boolean not null default false,
    creation_date timestamptz not null default now()
);

insert into country (code, name) values ('be', $$
    {
    "en": "Belgium"
}
$$);
insert into country (code, name) values ('fr', $$
    {
  "en": "France"
}
$$);