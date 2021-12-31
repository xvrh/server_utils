
create table country (
    code varchar(2) primary key,
    iso2 varchar(3) unique,
    name text not null
);

