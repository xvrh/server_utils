// GENERATED-FILE

import 'package:server_utils/database.dart';
import 'example_database_schema.dart';

extension DatabaseCrudExtension on Database {
  PageCrud get page => PageCrud(this);

  CountryCrud get country => CountryCrud(this);

  TimezoneCrud get timezone => TimezoneCrud(this);

  AppRoleCrud get appRole => AppRoleCrud(this);

  AppUserCrud get appUser => AppUserCrud(this);

  AppConfigurationCrud get appConfiguration => AppConfigurationCrud(this);

  MobileDeviceCrud get mobileDevice => MobileDeviceCrud(this);
}

class PageCrud {
  final Database _database;

  PageCrud(this._database);

  Future<Page> find(int id) {
    return _database.single(
      //language=sql
      'select * from page where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
      mapper: Page.fromRow,
    );
  }

  Future<Page> insert({
    int? id /* nextval('page_id_seq'::regclass) */,
    String? code,
    Object? title /* '{}'::jsonb */,
    Object? title2 /* '{}'::jsonb */,
    Object? title3 /* '{}'::jsonb */,
    Object? body /* '{}'::jsonb */,
    String? pageType,
  }) {
    return _database.insert(
      'page',
      values: {
        if (id != null) 'id': id,
        if (code != null) 'code': code,
        if (title != null) 'title': title,
        if (title2 != null) 'title2': title2,
        if (title3 != null) 'title3': title3,
        if (body != null) 'body': body,
        if (pageType != null) 'page_type': pageType,
      },
      mapper: Page.fromRow,
    );
  }

  Future<Page> updateFields() {
    throw UnimplementedError();
  }

  Future<Page> updateEntity(Page entity) {
    throw UnimplementedError();
  }

  Future<int> delete(int id) {
    return _database.execute(
      //language=sql
      'delete from page where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
    );
  }
}

class CountryCrud {
  final Database _database;

  CountryCrud(this._database);

  Future<Country> find(String code) {
    return _database.single(
      //language=sql
      'select * from country where code = :code::character varying',
      //language=none
      args: {
        'code': code,
      },
      mapper: Country.fromRow,
    );
  }

  Future<Country> insert({
    required String code,
    required String codeIso3,
    required String currency,
    required double latitude,
    required double longitude,
    required int phoneCode,
  }) {
    return _database.insert(
      'country',
      values: {
        'code': code,
        'code_iso3': codeIso3,
        'currency': currency,
        'latitude': latitude,
        'longitude': longitude,
        'phone_code': phoneCode,
      },
      mapper: Country.fromRow,
    );
  }

  Future<Country> updateFields() {
    throw UnimplementedError();
  }

  Future<Country> updateEntity(Country entity) {
    throw UnimplementedError();
  }

  Future<int> delete(String code) {
    return _database.execute(
      //language=sql
      'delete from country where code = :code::character varying',
      //language=none
      args: {
        'code': code,
      },
    );
  }
}

class TimezoneCrud {
  final Database _database;

  TimezoneCrud(this._database);

  Future<Timezone> find(String name) {
    return _database.single(
      //language=sql
      'select * from timezone where name = :name::text',
      //language=none
      args: {
        'name': name,
      },
      mapper: Timezone.fromRow,
    );
  }

  Future<Timezone> insert({
    required String name,
    String? country,
    String? aliasFor,
    required String latLong,
  }) {
    return _database.insert(
      'timezone',
      values: {
        'name': name,
        if (country != null) 'country': country,
        if (aliasFor != null) 'alias_for': aliasFor,
        'lat_long': latLong,
      },
      mapper: Timezone.fromRow,
    );
  }

  Future<Timezone> updateFields() {
    throw UnimplementedError();
  }

  Future<Timezone> updateEntity(Timezone entity) {
    throw UnimplementedError();
  }

  Future<int> delete(String name) {
    return _database.execute(
      //language=sql
      'delete from timezone where name = :name::text',
      //language=none
      args: {
        'name': name,
      },
    );
  }
}

class AppRoleCrud {
  final Database _database;

  AppRoleCrud(this._database);

  Future<AppRole> find(String code) {
    return _database.single(
      //language=sql
      'select * from app_role where code = :code::text',
      //language=none
      args: {
        'code': code,
      },
      mapper: AppRole.fromRow,
    );
  }

  Future<AppRole> insert({
    required String code,
    required int index,
    required String name,
    String? description /* ''::text */,
  }) {
    return _database.insert(
      'app_role',
      values: {
        'code': code,
        'index': index,
        'name': name,
        if (description != null) 'description': description,
      },
      mapper: AppRole.fromRow,
    );
  }

  Future<AppRole> updateFields() {
    throw UnimplementedError();
  }

  Future<AppRole> updateEntity(AppRole entity) {
    throw UnimplementedError();
  }

  Future<int> delete(String code) {
    return _database.execute(
      //language=sql
      'delete from app_role where code = :code::text',
      //language=none
      args: {
        'code': code,
      },
    );
  }
}

class AppUserCrud {
  final Database _database;

  AppUserCrud(this._database);

  Future<AppUser> find(int id) {
    return _database.single(
      //language=sql
      'select * from app_user where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
      mapper: AppUser.fromRow,
    );
  }

  Future<AppUser> insert({
    int? id /* nextval('app_user_id_seq'::regclass) */,
    required String role,
    required String email,
    DateTime? created /* now() */,
    DateTime? lastSeen,
    required String countryCode,
    int? configurationId /* 0 */,
    String? eulaVersion,
    String? firstName,
    String? middleName,
    String? lastName,
  }) {
    return _database.insert(
      'app_user',
      values: {
        if (id != null) 'id': id,
        'role': role,
        'email': email,
        if (created != null) 'created': created,
        if (lastSeen != null) 'last_seen': lastSeen,
        'country_code': countryCode,
        if (configurationId != null) 'configuration_id': configurationId,
        if (eulaVersion != null) 'eula_version': eulaVersion,
        if (firstName != null) 'first_name': firstName,
        if (middleName != null) 'middle_name': middleName,
        if (lastName != null) 'last_name': lastName,
      },
      mapper: AppUser.fromRow,
    );
  }

  Future<AppUser> updateFields() {
    throw UnimplementedError();
  }

  Future<AppUser> updateEntity(AppUser entity) {
    throw UnimplementedError();
  }

  Future<int> delete(int id) {
    return _database.execute(
      //language=sql
      'delete from app_user where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
    );
  }
}

class AppConfigurationCrud {
  final Database _database;

  AppConfigurationCrud(this._database);

  Future<AppConfiguration> find(int id) {
    return _database.single(
      //language=sql
      'select * from app_configuration where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
      mapper: AppConfiguration.fromRow,
    );
  }

  Future<AppConfiguration> insert({
    int? id /* nextval('app_configuration_id_seq'::regclass) */,
    bool? enableLogs,
  }) {
    return _database.insert(
      'app_configuration',
      values: {
        if (id != null) 'id': id,
        if (enableLogs != null) 'enable_logs': enableLogs,
      },
      mapper: AppConfiguration.fromRow,
    );
  }

  Future<AppConfiguration> updateFields() {
    throw UnimplementedError();
  }

  Future<AppConfiguration> updateEntity(AppConfiguration entity) {
    throw UnimplementedError();
  }

  Future<int> delete(int id) {
    return _database.execute(
      //language=sql
      'delete from app_configuration where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
    );
  }
}

class MobileDeviceCrud {
  final Database _database;

  MobileDeviceCrud(this._database);

  Future<MobileDevice> find(int id) {
    return _database.single(
      //language=sql
      'select * from mobile_device where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
      mapper: MobileDevice.fromRow,
    );
  }

  Future<MobileDevice> insert({
    int? id /* nextval('mobile_device_id_seq'::regclass) */,
    required int userId,
    DateTime? created /* now() */,
    DateTime? lastSeen /* now() */,
    required String deviceIdentifier,
    String? notificationToken,
    DateTime? notificationTokenUpdated,
    required String osName,
    String? osVersion /* ''::text */,
    String? osLocale /* ''::text */,
    String? manufacturer /* ''::text */,
    String? model /* ''::text */,
    required String appVersion,
    required String appLanguage,
    int? configurationId /* 0 */,
  }) {
    return _database.insert(
      'mobile_device',
      values: {
        if (id != null) 'id': id,
        'user_id': userId,
        if (created != null) 'created': created,
        if (lastSeen != null) 'last_seen': lastSeen,
        'device_identifier': deviceIdentifier,
        if (notificationToken != null) 'notification_token': notificationToken,
        if (notificationTokenUpdated != null)
          'notification_token_updated': notificationTokenUpdated,
        'os_name': osName,
        if (osVersion != null) 'os_version': osVersion,
        if (osLocale != null) 'os_locale': osLocale,
        if (manufacturer != null) 'manufacturer': manufacturer,
        if (model != null) 'model': model,
        'app_version': appVersion,
        'app_language': appLanguage,
        if (configurationId != null) 'configuration_id': configurationId,
      },
      mapper: MobileDevice.fromRow,
    );
  }

  Future<MobileDevice> updateFields() {
    throw UnimplementedError();
  }

  Future<MobileDevice> updateEntity(MobileDevice entity) {
    throw UnimplementedError();
  }

  Future<int> delete(int id) {
    return _database.execute(
      //language=sql
      'delete from mobile_device where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
    );
  }
}
