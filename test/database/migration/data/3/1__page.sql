create table page
(
    id            serial primary key,
    url           text        not null,
    creation_time timestamptz not null default now(),
    birth_date    date,
    price         numeric     not null default 0
);

insert into page (url, birth_date, price)
values ('the-url', '2019-03-30', 50.3);

create table person
(
    id   serial primary key,
    name text
)