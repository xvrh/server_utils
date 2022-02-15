// GENERATED-CODE: do not edit
// Code is generated from select.queries.dart

part of 'select.queries.dart';

extension MyQueries on Database {
  Future<AppUser> findUser(int id) {
    return Query<AppUser>(
      this,
      //language=sql
      r'''
    select *
from app_user
where id = :id::int
''',
      arguments: {
        'id': id,
      },
      mapper: AppUser.fromRow,
    ).single;
  }

  Future<AppUser> findUserByEmail(String email) {
    return Query<AppUser>(
      this,
      //language=sql
      r'''
select *
from app_user
where email = :email::text
''',
      arguments: {
        'email': email,
      },
      mapper: AppUser.fromRow,
    ).single;
  }

  Query<AppUser> queryByCountry(String country) {
    return Query<AppUser>(
      this,
      //language=sql
      r'''
select *
from app_user
where country_code = :country::text
''',
      arguments: {
        'country': country,
      },
      mapper: AppUser.fromRow,
    );
  }

  Future<List<String>> allNames() {
    return Query<String>.singleColumn(this,
        //language=sql
        r'''
select first_name
from app_user
''', arguments: {}).list;
  }

  Query<AppUser> allUsers() {
    return Query<AppUser>(
      this,
      //language=sql
      r'''
select *
from app_user
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
returning *
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
where id = :userId::int
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
where id = :deviceId
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
where notification_token_updated < :refDate::date
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
where notification_token_updated < :date
''', arguments: {
      'date': date,
    }).affectedRows;
  }

// ignore: unused_element
  void _simulateUseElements() {
    print(_MyQueries(this).findUser);
    print(_MyQueries(this).findUserByEmail);
    print(_MyQueries(this).queryByCountry);
    print(_MyQueries(this).allNames);
    print(_MyQueries(this).allUsers);
    print(_MyQueries(this).setUserName);
    print(_MyQueries(this).deleteUser);
    print(_MyQueries(this).tokenForDevice);
    print(_MyQueries(this).devicesOlderThan);
    print(_MyQueries(this).deleteDeviceOlderThan);
  }
}

class MobileDeviceToken {
  static final columns = _MobileDeviceTokenColumns();

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

  factory MobileDeviceToken.fromRow(Map<String, dynamic> row) {
    return MobileDeviceToken(
      userId: row['user_id']! as int,
      notificationToken: row['notification_token'] as String?,
      manufacturer: row['manufacturer']! as String,
      deviceIdentifier: row['device_identifier']! as String,
    );
  }

  factory MobileDeviceToken.fromJson(Map<String, Object?> json) {
    return MobileDeviceToken(
      userId: (json['userId']! as num).toInt(),
      notificationToken: json['notificationToken'] as String?,
      manufacturer: json['manufacturer']! as String,
      deviceIdentifier: json['deviceIdentifier']! as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'userId': userId,
      'notificationToken': notificationToken,
      'manufacturer': manufacturer,
      'deviceIdentifier': deviceIdentifier,
    };
  }

  MobileDeviceToken copyWith({
    int? userId,
    String? notificationToken,
    bool? clearNotificationToken,
    String? manufacturer,
    String? deviceIdentifier,
  }) {
    return MobileDeviceToken(
      userId: userId ?? this.userId,
      notificationToken: (clearNotificationToken ?? false)
          ? null
          : notificationToken ?? this.notificationToken,
      manufacturer: manufacturer ?? this.manufacturer,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
    );
  }
}

class _MobileDeviceTokenColumns {
  final userId = Column<MobileDeviceToken>('user_id');
  final notificationToken = Column<MobileDeviceToken>('notification_token');
  final manufacturer = Column<MobileDeviceToken>('manufacturer');
  final deviceIdentifier = Column<MobileDeviceToken>('device_identifier');
  late final list = [userId, notificationToken, manufacturer, deviceIdentifier];
}
