--@extension SelectQueries
--@import 'example_database_schema.dart';

/***********************
AppUser findUser(int id)
************************/
select *
from app_user
where id = :id::int;

/***********************
AppUser? findUserByEmail(String email)
************************/
select *
from app_user
where email = :email::text;

/***********************
Query<AppUser> queryByCountry(String country)
************************/
select *
from app_user
where country_code = :country::text;

/***********************
List<String?> allNames()
************************/
select first_name
from app_user;

/***********************
Query<AppUser> allUsers()
************************/
select *
from app_user;

/***********************
AppUser setUserName(int userId, {String? firstName, String? lastName})
************************/
update app_user
set first_name = coalesce(:firstName, first_name),
    last_name  = coalesce(:lastName, last_name)
where id = :userId::int
returning *;

/***********************
void deleteUser(int userId)
************************/
delete
from app_user
where id = :userId::int;

/***********************
MobileDeviceToken tokenForDevice(int deviceId)
projection MobileDeviceToken(* not null)
************************/
select user_id, notification_token, lower(manufacturer) as manufacturer, device_identifier
from mobile_device
where id = :deviceId;

/***********************
MobileDevice devicesOlderThan(DateTime refDate)
************************/
select *
from mobile_device
where notification_token_updated < :refDate::date;

/***********************
void deleteDeviceOlderThan(DateTime date)
************************/
delete
from mobile_device
where notification_token_updated < :date;

