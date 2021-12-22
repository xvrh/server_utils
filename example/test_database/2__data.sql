insert into country (code, code_iso3, currency, latitude, longitude, phone_code)
values ('BE', 'BEL', 'EUR', 0, 0, 32);
insert into country (code, code_iso3, currency, latitude, longitude, phone_code)
values ('FR', 'FRA', 'EUR', 0, 0, 32);

insert into app_user (email, country_code, role, first_name)
values ('info@xaha.dev', 'BE', 'ADMIN', 'M. X');

insert into app_user (email, country_code, role)
values ('info@email.dev', 'FR', 'USER');

insert into page (code)
values ('Home');