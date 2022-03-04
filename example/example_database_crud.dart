// GENERATED-FILE

import 'package:server_utils/database.dart';
import 'example_database_schema.dart';

extension DatabaseCrudExtension on Database {
  CmsPageCrud get cmsPage => CmsPageCrud(this);

  AppConfigurationCrud get appConfiguration => AppConfigurationCrud(this);

  CountryCrud get country => CountryCrud(this);

  TimezoneCrud get timezone => TimezoneCrud(this);

  AppUserCrud get appUser => AppUserCrud(this);

  MobileDeviceCrud get mobileDevice => MobileDeviceCrud(this);

  ConsentCrud get consent => ConsentCrud(this);
}

class CmsPageCrud {
  final Database _database;

  CmsPageCrud(this._database);

  Future<CmsPage> find(int id) {
    return _database.single(
      //language=sql
      'select * from cms_page where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
      mapper: CmsPage.fromRow,
    );
  }

  Future<CmsPage?> findOrNull(int id) {
    return _database.singleOrNull(
      //language=sql
      'select * from cms_page where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
      mapper: CmsPage.fromRow,
    );
  }

  Future<CmsPage> insert({
    int? id /* nextval('cms_page_id_seq'::regclass) */,
    String? code,
    Object? title /* '{}'::jsonb */,
    Object? title2 /* '{}'::jsonb */,
    Object? title3 /* '{}'::jsonb */,
    Object? body /* '{}'::jsonb */,
    String? pageType,
  }) {
    return _database.insert(
      'cms_page',
      values: {
        if (id != null) 'id': id,
        if (code != null) 'code': code,
        if (title != null) 'title': title,
        if (title2 != null) 'title2': title2,
        if (title3 != null) 'title3': title3,
        if (body != null) 'body': body,
        if (pageType != null) 'page_type': pageType,
      },
      mapper: CmsPage.fromRow,
    );
  }

  Future<CmsPage> update(
    int id, {
    String? code,
    bool? clearCode,
    Object? title,
    Object? title2,
    Object? title3,
    bool? clearTitle3,
    Object? body,
    String? pageType,
    bool? clearPageType,
  }) {
    return _database.update(
      CmsPage.table,
      where: {
        'id': id,
      },
      set: {
        if (code != null) 'code': code,
        if (title != null) 'title': title,
        if (title2 != null) 'title2': title2,
        if (title3 != null) 'title3': title3,
        if (body != null) 'body': body,
        if (pageType != null) 'page_type': pageType,
      },
      clear: [
        if (clearCode ?? false) 'code',
        if (clearTitle3 ?? false) 'title3',
        if (clearPageType ?? false) 'page_type',
      ],
      mapper: CmsPage.fromRow,
    );
  }

  Future<CmsPage> updateEntity(CmsPage entity) {
    return update(
      entity.id,
      code: entity.code,
      clearCode: entity.code == null,
      title: entity.title,
      title2: entity.title2,
      title3: entity.title3,
      clearTitle3: entity.title3 == null,
      body: entity.body,
      pageType: entity.pageType,
      clearPageType: entity.pageType == null,
    );
  }

  Future<int> delete(int id) {
    return _database.execute(
      //language=sql
      'delete from cms_page where id = :id::integer',
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

  Future<AppConfiguration?> findOrNull(int id) {
    return _database.singleOrNull(
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

  Future<AppConfiguration> update(
    int id, {
    bool? enableLogs,
    bool? clearEnableLogs,
  }) {
    return _database.update(
      AppConfiguration.table,
      where: {
        'id': id,
      },
      set: {
        if (enableLogs != null) 'enable_logs': enableLogs,
      },
      clear: [
        if (clearEnableLogs ?? false) 'enable_logs',
      ],
      mapper: AppConfiguration.fromRow,
    );
  }

  Future<AppConfiguration> updateEntity(AppConfiguration entity) {
    return update(
      entity.id,
      enableLogs: entity.enableLogs,
      clearEnableLogs: entity.enableLogs == null,
    );
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

  Future<Country?> findOrNull(String code) {
    return _database.singleOrNull(
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

  Future<Country> update(
    String code, {
    String? codeIso3,
    String? currency,
    double? latitude,
    double? longitude,
    int? phoneCode,
  }) {
    return _database.update(
      Country.table,
      where: {
        'code': code,
      },
      set: {
        if (codeIso3 != null) 'code_iso3': codeIso3,
        if (currency != null) 'currency': currency,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (phoneCode != null) 'phone_code': phoneCode,
      },
      mapper: Country.fromRow,
    );
  }

  Future<Country> updateEntity(Country entity) {
    return update(
      entity.code,
      codeIso3: entity.codeIso3,
      currency: entity.currency,
      latitude: entity.latitude,
      longitude: entity.longitude,
      phoneCode: entity.phoneCode,
    );
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

  Future<Timezone?> findOrNull(String name) {
    return _database.singleOrNull(
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

  Future<Timezone> update(
    String name, {
    String? country,
    bool? clearCountry,
    String? aliasFor,
    bool? clearAliasFor,
    String? latLong,
  }) {
    return _database.update(
      Timezone.table,
      where: {
        'name': name,
      },
      set: {
        if (country != null) 'country': country,
        if (aliasFor != null) 'alias_for': aliasFor,
        if (latLong != null) 'lat_long': latLong,
      },
      clear: [
        if (clearCountry ?? false) 'country',
        if (clearAliasFor ?? false) 'alias_for',
      ],
      mapper: Timezone.fromRow,
    );
  }

  Future<Timezone> updateEntity(Timezone entity) {
    return update(
      entity.name,
      country: entity.country,
      clearCountry: entity.country == null,
      aliasFor: entity.aliasFor,
      clearAliasFor: entity.aliasFor == null,
      latLong: entity.latLong,
    );
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

  Future<AppUser?> findOrNull(int id) {
    return _database.singleOrNull(
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
    required AppRole role,
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
        'role': role.value,
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

  Future<AppUser> update(
    int id, {
    AppRole? role,
    String? email,
    DateTime? created,
    DateTime? lastSeen,
    bool? clearLastSeen,
    String? countryCode,
    int? configurationId,
    String? eulaVersion,
    bool? clearEulaVersion,
    String? firstName,
    bool? clearFirstName,
    String? middleName,
    bool? clearMiddleName,
    String? lastName,
    bool? clearLastName,
  }) {
    return _database.update(
      AppUser.table,
      where: {
        'id': id,
      },
      set: {
        if (role != null) 'role': role.value,
        if (email != null) 'email': email,
        if (created != null) 'created': created,
        if (lastSeen != null) 'last_seen': lastSeen,
        if (countryCode != null) 'country_code': countryCode,
        if (configurationId != null) 'configuration_id': configurationId,
        if (eulaVersion != null) 'eula_version': eulaVersion,
        if (firstName != null) 'first_name': firstName,
        if (middleName != null) 'middle_name': middleName,
        if (lastName != null) 'last_name': lastName,
      },
      clear: [
        if (clearLastSeen ?? false) 'last_seen',
        if (clearEulaVersion ?? false) 'eula_version',
        if (clearFirstName ?? false) 'first_name',
        if (clearMiddleName ?? false) 'middle_name',
        if (clearLastName ?? false) 'last_name',
      ],
      mapper: AppUser.fromRow,
    );
  }

  Future<AppUser> updateEntity(AppUser entity) {
    return update(
      entity.id,
      role: entity.role,
      email: entity.email,
      created: entity.created,
      lastSeen: entity.lastSeen,
      clearLastSeen: entity.lastSeen == null,
      countryCode: entity.countryCode,
      configurationId: entity.configurationId,
      eulaVersion: entity.eulaVersion,
      clearEulaVersion: entity.eulaVersion == null,
      firstName: entity.firstName,
      clearFirstName: entity.firstName == null,
      middleName: entity.middleName,
      clearMiddleName: entity.middleName == null,
      lastName: entity.lastName,
      clearLastName: entity.lastName == null,
    );
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

  Future<MobileDevice?> findOrNull(int id) {
    return _database.singleOrNull(
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

  Future<MobileDevice> update(
    int id, {
    int? userId,
    DateTime? created,
    DateTime? lastSeen,
    String? deviceIdentifier,
    String? notificationToken,
    bool? clearNotificationToken,
    DateTime? notificationTokenUpdated,
    bool? clearNotificationTokenUpdated,
    String? osName,
    String? osVersion,
    String? osLocale,
    String? manufacturer,
    String? model,
    String? appVersion,
    String? appLanguage,
    int? configurationId,
  }) {
    return _database.update(
      MobileDevice.table,
      where: {
        'id': id,
      },
      set: {
        if (userId != null) 'user_id': userId,
        if (created != null) 'created': created,
        if (lastSeen != null) 'last_seen': lastSeen,
        if (deviceIdentifier != null) 'device_identifier': deviceIdentifier,
        if (notificationToken != null) 'notification_token': notificationToken,
        if (notificationTokenUpdated != null)
          'notification_token_updated': notificationTokenUpdated,
        if (osName != null) 'os_name': osName,
        if (osVersion != null) 'os_version': osVersion,
        if (osLocale != null) 'os_locale': osLocale,
        if (manufacturer != null) 'manufacturer': manufacturer,
        if (model != null) 'model': model,
        if (appVersion != null) 'app_version': appVersion,
        if (appLanguage != null) 'app_language': appLanguage,
        if (configurationId != null) 'configuration_id': configurationId,
      },
      clear: [
        if (clearNotificationToken ?? false) 'notification_token',
        if (clearNotificationTokenUpdated ?? false)
          'notification_token_updated',
      ],
      mapper: MobileDevice.fromRow,
    );
  }

  Future<MobileDevice> updateEntity(MobileDevice entity) {
    return update(
      entity.id,
      userId: entity.userId,
      created: entity.created,
      lastSeen: entity.lastSeen,
      deviceIdentifier: entity.deviceIdentifier,
      notificationToken: entity.notificationToken,
      clearNotificationToken: entity.notificationToken == null,
      notificationTokenUpdated: entity.notificationTokenUpdated,
      clearNotificationTokenUpdated: entity.notificationTokenUpdated == null,
      osName: entity.osName,
      osVersion: entity.osVersion,
      osLocale: entity.osLocale,
      manufacturer: entity.manufacturer,
      model: entity.model,
      appVersion: entity.appVersion,
      appLanguage: entity.appLanguage,
      configurationId: entity.configurationId,
    );
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

class ConsentCrud {
  final Database _database;

  ConsentCrud(this._database);

  Future<Consent> find(int id) {
    return _database.single(
      //language=sql
      'select * from consent where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
      mapper: Consent.fromRow,
    );
  }

  Future<Consent?> findOrNull(int id) {
    return _database.singleOrNull(
      //language=sql
      'select * from consent where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
      mapper: Consent.fromRow,
    );
  }

  Future<Consent> insert({
    int? id /* nextval('consent_id_seq'::regclass) */,
    required ConsentType type,
  }) {
    return _database.insert(
      'consent',
      values: {
        if (id != null) 'id': id,
        'type': type.value,
      },
      mapper: Consent.fromRow,
    );
  }

  Future<Consent> update(
    int id, {
    ConsentType? type,
  }) {
    return _database.update(
      Consent.table,
      where: {
        'id': id,
      },
      set: {
        if (type != null) 'type': type.value,
      },
      mapper: Consent.fromRow,
    );
  }

  Future<Consent> updateEntity(Consent entity) {
    return update(
      entity.id,
      type: entity.type,
    );
  }

  Future<int> delete(int id) {
    return _database.execute(
      //language=sql
      'delete from consent where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
    );
  }
}
