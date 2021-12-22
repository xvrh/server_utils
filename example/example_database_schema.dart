// GENERATED-FILE
class Page {
  final dynamic body;
  final String? code;
  final dynamic title;
  final int id;
  final dynamic title2;
  final String? pageType;

  Page({
    required this.body,
    this.code,
    required this.title,
    required this.id,
    required this.title2,
    this.pageType,
  });

  static Page fromRow(Map<String, dynamic> row) {
    return Page(
      body: row['body']! as dynamic,
      code: row['code'] as String?,
      title: row['title']! as dynamic,
      id: row['id']! as int,
      title2: row['title2']! as dynamic,
      pageType: row['page_type'] as String?,
    );
  }
}

class AppConfiguration {
  final int id;
  final bool? enableLogs;

  AppConfiguration({
    required this.id,
    this.enableLogs,
  });

  static AppConfiguration fromRow(Map<String, dynamic> row) {
    return AppConfiguration(
      id: row['id']! as int,
      enableLogs: row['enable_logs'] as bool?,
    );
  }
}

class Country {
  final int phoneCode;
  final double latitude;
  final String code;
  final String currency;
  final String codeIso3;
  final double longitude;

  Country({
    required this.phoneCode,
    required this.latitude,
    required this.code,
    required this.currency,
    required this.codeIso3,
    required this.longitude,
  });

  static Country fromRow(Map<String, dynamic> row) {
    return Country(
      phoneCode: row['phone_code']! as int,
      latitude: row['latitude']! as double,
      code: row['code']! as String,
      currency: row['currency']! as String,
      codeIso3: row['code_iso3']! as String,
      longitude: row['longitude']! as double,
    );
  }
}

class Timezone {
  final String? country;
  final String name;
  final String latLong;
  final String? aliasFor;

  Timezone({
    this.country,
    required this.name,
    required this.latLong,
    this.aliasFor,
  });

  static Timezone fromRow(Map<String, dynamic> row) {
    return Timezone(
      country: row['country'] as String?,
      name: row['name']! as String,
      latLong: row['lat_long']! as String,
      aliasFor: row['alias_for'] as String?,
    );
  }
}

class AppRole {
  final int index;
  final String description;
  final String code;
  final String name;

  AppRole({
    required this.index,
    required this.description,
    required this.code,
    required this.name,
  });

  static AppRole fromRow(Map<String, dynamic> row) {
    return AppRole(
      index: row['index']! as int,
      description: row['description']! as String,
      code: row['code']! as String,
      name: row['name']! as String,
    );
  }
}

class AppUser {
  final String countryCode;
  final String? eulaVersion;
  final int configurationId;
  final String? firstName;
  final String email;
  final int id;
  final DateTime created;
  final String role;
  final String? middleName;
  final String? lastName;
  final DateTime? lastSeen;

  AppUser({
    required this.countryCode,
    this.eulaVersion,
    required this.configurationId,
    this.firstName,
    required this.email,
    required this.id,
    required this.created,
    required this.role,
    this.middleName,
    this.lastName,
    this.lastSeen,
  });

  static AppUser fromRow(Map<String, dynamic> row) {
    return AppUser(
      countryCode: row['country_code']! as String,
      eulaVersion: row['eula_version'] as String?,
      configurationId: row['configuration_id']! as int,
      firstName: row['first_name'] as String?,
      email: row['email']! as String,
      id: row['id']! as int,
      created: row['created']! as DateTime,
      role: row['role']! as String,
      middleName: row['middle_name'] as String?,
      lastName: row['last_name'] as String?,
      lastSeen: row['last_seen'] as DateTime?,
    );
  }
}

class MobileDevice {
  final DateTime? notificationTokenUpdated;
  final String osVersion;
  final String appLanguage;
  final DateTime created;
  final int id;
  final DateTime lastSeen;
  final String? notificationToken;
  final String osName;
  final String deviceIdentifier;
  final String appVersion;
  final int configurationId;
  final int userId;
  final String osLocale;
  final String model;
  final String manufacturer;

  MobileDevice({
    this.notificationTokenUpdated,
    required this.osVersion,
    required this.appLanguage,
    required this.created,
    required this.id,
    required this.lastSeen,
    this.notificationToken,
    required this.osName,
    required this.deviceIdentifier,
    required this.appVersion,
    required this.configurationId,
    required this.userId,
    required this.osLocale,
    required this.model,
    required this.manufacturer,
  });

  static MobileDevice fromRow(Map<String, dynamic> row) {
    return MobileDevice(
      notificationTokenUpdated: row['notification_token_updated'] as DateTime?,
      osVersion: row['os_version']! as String,
      appLanguage: row['app_language']! as String,
      created: row['created']! as DateTime,
      id: row['id']! as int,
      lastSeen: row['last_seen']! as DateTime,
      notificationToken: row['notification_token'] as String?,
      osName: row['os_name']! as String,
      deviceIdentifier: row['device_identifier']! as String,
      appVersion: row['app_version']! as String,
      configurationId: row['configuration_id']! as int,
      userId: row['user_id']! as int,
      osLocale: row['os_locale']! as String,
      model: row['model']! as String,
      manufacturer: row['manufacturer']! as String,
    );
  }
}
