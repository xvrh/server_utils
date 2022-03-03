insert into cms_page (code)
values ('Contact');

create type consent_type as enum ('terms_of_use', 'privacy_policy');

create table consent
(
    id   serial primary key,
    type consent_type not null
);