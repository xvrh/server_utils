// GENERATED-CODE: do not edit
// Code is generated from select.queries.sql

import 'package:server_utils/database.dart';
import 'example_database_schema.dart';

extension SelectQueries on Database {
  Future<AppUser> findUser(int id) {
    return Query<AppUser>(
      this,
      //language=sql
      r'''
select *
from app_user
where id = :id::int;
''',
      arguments: {
        'id': id,
      },
      mapper: AppUser.fromRow,
    ).single;
  }

  Future<AppUser?> findUserByEmail(String email) {
    return Query<AppUser?>(
      this,
      //language=sql
      r'''
select *
from app_user
where email = :email::text;
''',
      arguments: {
        'email': email,
      },
      mapper: AppUser.fromRow,
    ).singleOrNull;
  }

  Query<AppUser> queryByCountry(String country) {
    return Query<AppUser>(
      this,
      //language=sql
      r'''
select *
from app_user
where country_code = :country::text;
''',
      arguments: {
        'country': country,
      },
      mapper: AppUser.fromRow,
    );
  }

  Future<List<String?>> allNames() {
    return Query<String?>.singleColumn(this,
        //language=sql
        r'''
select first_name
from app_user;
''', arguments: {}).list;
  }

  Query<AppUser> allUsers() {
    return Query<AppUser>(
      this,
      //language=sql
      r'''
select *
from app_user;
''',
      arguments: {},
      mapper: AppUser.fromRow,
    );
  }

  Future<AppUser> setUserName(int userId,
      {String? firstName, String? lastName}) {
    return Query<AppUser>(
      this,
      //language=sql
      r'''
update app_user
set first_name = coalesce(:firstName, first_name),
    last_name  = coalesce(:lastName, last_name)
where id = :userId::int
returning *;
''',
      arguments: {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
      },
      mapper: AppUser.fromRow,
    ).single;
  }

  Future<int> deleteUser(int userId) {
    return Query<void>.noResult(this,
        //language=sql
        r'''
delete
from app_user
where id = :userId::int;
''', arguments: {
      'userId': userId,
    }).affectedRows;
  }

  Future<MobileDeviceToken> tokenForDevice(int deviceId) {
    return Query<MobileDeviceToken>(
      this,
      //language=sql
      r'''
select user_id, notification_token, lower(manufacturer) as manufacturer, device_identifier
from mobile_device
where id = :deviceId;
''',
      arguments: {
        'deviceId': deviceId,
      },
      mapper: MobileDeviceToken.fromRow,
    ).single;
  }

  Future<MobileDevice> devicesOlderThan(DateTime refDate) {
    return Query<MobileDevice>(
      this,
      //language=sql
      r'''
select *
from mobile_device
where notification_token_updated < :refDate::date;
''',
      arguments: {
        'refDate': refDate,
      },
      mapper: MobileDevice.fromRow,
    ).single;
  }

  Future<int> deleteDeviceOlderThan(DateTime date) {
    return Query<void>.noResult(this,
        //language=sql
        r'''
delete
from mobile_device
where notification_token_updated < :date;
''', arguments: {
      'date': date,
    }).affectedRows;
  }
}

class MobileDeviceToken {
  final int userId;
  final String? notificationToken;
  final String manufacturer;
  final String deviceIdentifier;

  MobileDeviceToken({
    required this.userId,
    this.notificationToken,
    required this.manufacturer,
    required this.deviceIdentifier,
  });

  static MobileDeviceToken fromRow(Map<String, dynamic> row) {
    return MobileDeviceToken(
      userId: row['user_id']! as int,
      notificationToken: row['notification_token'] as String?,
      manufacturer: row['manufacturer']! as String,
      deviceIdentifier: row['device_identifier']! as String,
    );
  }
}
