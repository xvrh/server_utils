create table company
(
    id   serial primary key,
    name text not null
);

create table contact
(
    id         serial primary key,
    first_name text                        not null,
    last_name  text                        not null,
    company_id int references company (id) not null
);

insert into company (name) values ('Nike');
insert into company (name) values ('Pumas');
insert into company (name) values ('Adidas');