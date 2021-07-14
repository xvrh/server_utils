
create table film (
    id serial primary key,
    name text not null,
    year int null
);

create table actor (
    id serial primary key,
    first_name text not null,
    last_name text not null,
    birth_date date null
);

create table film_actor (
    film_id int not null references film(id),
    actor_id int not null references actor(id),
    primary key (film_id, actor_id)
);