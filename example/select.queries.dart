import 'package:server_utils/database.dart';

import 'example_database_schema.dart';

part 'select.queries.gen.dart';

extension _MyQueries on Database {
  AppUser findUser(int id) {
    //language=sql
    q('''
    select *
from app_user
where id = :id::int;
    ''');
  }

  AppUser? findUserByEmail(String email) {
    //language=sql
    q('''select *
from app_user
where email = :email::text;
    ''');
  }

  Query<AppUser> queryByCountry(String country) => q(
      //language=sql
      '''select *
from app_user
where country_code = :country::text;
    ''');

  List<String?> allNames() {
    //language=sql
    q('''select first_name
from app_user;
    ''');
  }

  Query<AppUser> allUsers() {
    //language=sql
    q('''select *
from app_user;
    ''');
  }

  AppUser setUserName(int userId, {String? firstName, String? lastName}) {
    testValues = {
      firstName = 'name',
    };
    //language=sql
    q('''update app_user
set first_name = coalesce(:firstName, first_name),
last_name  = coalesce(:lastName, last_name)
where id = :userId::int
returning *;
    ''');
  }

  void deleteUser(int userId) {
    //language=sql
    q('''delete
from app_user
where id = :userId::int;
    ''');
  }

  MobileDeviceToken tokenForDevice(int deviceId) {
    projection = {
      '*': Col(nullable: false),
    };
    //language=sql
    q('''select user_id, notification_token, lower(manufacturer) as manufacturer, device_identifier
from mobile_device
where id = :deviceId;
    ''');
  }

  MobileDevice devicesOlderThan(DateTime refDate) {
    //language=sql
    q('''select *
from mobile_device
where notification_token_updated < :refDate::date;
    ''');
  }

  void deleteDeviceOlderThan(DateTime date) {
    //language=sql
    q('''delete
from mobile_device
where notification_token_updated < :date;
    ''');
  }
}
