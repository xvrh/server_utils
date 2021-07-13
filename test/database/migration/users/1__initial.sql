create table app_configuration
(
    id               serial primary key,
    force_app_review boolean null,
    enable_logs      boolean null
);

create table app_user
(
    id               serial primary key,
    email            text not null unique,
    last_seen        timestamptz,
    configuration_id int  not null references app_configuration (id),
    eula_version     text null,
    first_name       text null,
    last_name        text null
);

-- Each time the app is open, insert or update the record in this database
create table mobile_device
(
    id                         serial primary key,
    created                    timestamptz not null default now(),
    last_seen                  timestamptz not null default now(),
    device_identifier          text        not null unique,
    notification_token         text        null,
    notification_token_updated timestamptz,
    os_name                    text        not null,
    os_version                 text        not null default '',
    os_locale                  text        not null default '',
    manufacturer               text        not null default '',
    model                      text        not null default '',
    app_version                text        not null,
    app_language               text        not null,
    configuration_id           int         not null references app_configuration (id)
);

create function mobile_device_updated() returns trigger as
$$
begin
    if (new.notification_token != old.notification_token) then
        new.notification_token_updated := now();
    end if;
    new.last_seen := now();
    return new;
end;
$$;

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
$$;

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

create table user_device
(
    user_id   int         not null references app_user (id) on delete cascade,
    device_id int         not null references mobile_device (id) on delete cascade,
    created   timestamptz not null default now(),
    primary key (user_id, device_id)
);
