create table cms_page
(
    id                        serial primary key,
    url                       text not null,
    title_/*#language*/       text not null,
    description_/*#language*/ text
);

insert into cms_page (url /*,title_en?*//*,title_fr*/)
values ('the-slug/3'/*,'English title' *//*'Le titre français'*/);

insert into page (url,
                  title_en /*#language en */,
                  title_fr /*#language fr */)
values ('the-slug/3',
        'English title' /*if language en*/,
        'Le titre français' /*if language fr*/);

create table page2
(
    id                        serial primary key,
    url                       text not null
    --#for language in languages
    ,
    title_/*#language*/       text not null,
    description_/*#language*/ text
    --#end for
);

insert into page2 ( url
    --#if languages contains en
                  , title_en
    --#end if
    --#if languages contains fr
                  , title_fr
    --#end if
)
values ( 'the-slug/3'
           --#if languages contains en
       , 'English title'
           --#endif
           --#if languages contains fr
       , 'Le titre français'
           --#endif
       );

create table block
(
    id      serial primary key,
    --# start block
    content jsonb not null
    --# end
);

create table app_user
(
    id              serial primary key,
    creation_date   timestamptz not null default now(),
    name            text        not null,
    hashed_password text        not null,
    enabled         boolean     not null default true
);

create table revision
(
    id       serial primary key,
    user_id  int         not null references app_user (id),
    date     timestamptz not null default now(),
    is_draft bool        not null default false
);

create table block_revision
(
    revision_id serial primary key references revision (id),
    -- TODO(xha): garder une valeur qui indique la différence par rapport à la version précédente
    --            faire une pondération sur chaque champ (avec 2 algo différentes (total % caractère qui change et
    --            nombre de champ qui change).
    entity_id   int not null
    --# use block
);