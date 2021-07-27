
create table country (
    code char(2) primary key,
    iso2 char(3) unique,
    name text not null
);

