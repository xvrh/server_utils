create domain translated_text jsonb not null default $${}$$;

create table cms_page
(
    id        serial primary key,
    code      text  null,
    title     translated_text default $${}$$,
    title2    jsonb not null  default $${}$$,
    title3    jsonb null      default $${}$$,
    body      translated_text,
    page_type text  null
);

create table app_configuration
(
    id          serial primary key,
    enable_logs boolean null
);

-- http://download.geonames.org/export/dump/readme.txt
create table country
(
    code       varchar(2) primary key,
    code_iso3  varchar(3) not null,
    currency   varchar(3) not null,
    latitude   float      not null,
    longitude  float      not null,
    phone_code int        not null
);

create table timezone
(
    name      text primary key,
    country   varchar(2) null references country (code),
    alias_for text       null references timezone (name),
    lat_long  text       not null
);

create table app_role
(
    code        text not null primary key,
    index       int  not null,
    name        text not null,
    description text not null default ''
);

insert into app_role (code, index, name)
values ('ADMIN', 100, 'Admin'),
       ('USER', 0, 'User');

create table app_user
(
    id               serial primary key,
    role             text        not null references app_role (code),
    email            text        not null unique,
    created          timestamptz not null default now(),
    last_seen        timestamptz,
    country_code     varchar(2)  not null references country (code),
    -- Filled by the app_user_inserted trigger
    configuration_id int         not null default 0 references app_configuration (id),
    eula_version     text        null,
    first_name       text        null,
    middle_name      text        null,
    last_name        text        null
);

-- Each time the app is open, insert or update the record in this database
create table mobile_device
(
    id                         serial primary key,
    user_id                    int         not null references app_user (id),
    created                    timestamptz not null default now(),
    last_seen                  timestamptz not null default now(),
    device_identifier          text        not null unique,
    notification_token         text        null,
    notification_token_updated timestamptz null,
    os_name                    text        not null,
    os_version                 text        not null default '',
    os_locale                  text        not null default '',
    manufacturer               text        not null default '',
    model                      text        not null default '',
    app_version                text        not null,
    app_language               text        not null,
    -- Filled by the mobile_device_inserted trigger
    configuration_id           int         not null default 0 references app_configuration (id)
);

create function app_user_inserted() returns trigger as
$$
declare
    config_id int;
begin
    insert into app_configuration default values returning id into config_id;
    new.configuration_id = config_id;
    return new;
end;
$$ language plpgsql;

create trigger
    app_user_inserted
    before insert
    on
        app_user
    for each row
execute procedure
    app_user_inserted();

create function mobile_device_inserted() returns trigger as
$$
declare
    config_id int;
begin
    insert into app_configuration default values returning id into config_id;
    new.configuration_id = config_id;
    return new;
end;
$$ language plpgsql;

create trigger
    mobile_device_inserted
    before insert
    on
        mobile_device
    for each row
execute procedure
    mobile_device_inserted();

create function mobile_device_updated() returns trigger as
$$
begin
    if (new.notification_token != old.notification_token) then
        new.notification_token_updated := now();
    end if;
    new.last_seen := now();
    return new;
end;
$$ language plpgsql;

create trigger
    trigger_mobile_device_updated
    before update
    on
        mobile_device
    for each row
execute procedure
    mobile_device_updated();

create function device_or_user_deleted() returns trigger as
$$
begin
    delete
    from app_configuration
    where id = old.configuration_id;
    return old;
end;
$$ language plpgsql;

create trigger
    trigger_device_deleted
    after delete
    on
        mobile_device
    for each row
execute procedure
    device_or_user_deleted();

create trigger
    trigger_user_deleted
    after delete
    on
        app_user
    for each row
execute procedure
    device_or_user_deleted();
