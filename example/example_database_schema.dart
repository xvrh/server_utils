// GENERATED-FILE
class Page {
  final String? code;
  final dynamic body;
  final dynamic title2;
  final int id;
  final dynamic title;

  Page({
    this.code,
    required this.body,
    required this.title2,
    required this.id,
    required this.title,
  });

  static Page fromRow(Map<String, dynamic> row) {
    return Page(
      code: row['code'] as String?,
      body: row['body']! as dynamic,
      title2: row['title2']! as dynamic,
      id: row['id']! as int,
      title: row['title']! as dynamic,
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
  final String codeIso3;
  final double longitude;
  final int phoneCode;
  final double latitude;
  final String code;
  final String currency;

  Country({
    required this.codeIso3,
    required this.longitude,
    required this.phoneCode,
    required this.latitude,
    required this.code,
    required this.currency,
  });

  static Country fromRow(Map<String, dynamic> row) {
    return Country(
      codeIso3: row['code_iso3']! as String,
      longitude: row['longitude']! as double,
      phoneCode: row['phone_code']! as int,
      latitude: row['latitude']! as double,
      code: row['code']! as String,
      currency: row['currency']! as String,
    );
  }
}

class Timezone {
  final String latLong;
  final String name;
  final String? aliasFor;
  final String? country;

  Timezone({
    required this.latLong,
    required this.name,
    this.aliasFor,
    this.country,
  });

  static Timezone fromRow(Map<String, dynamic> row) {
    return Timezone(
      latLong: row['lat_long']! as String,
      name: row['name']! as String,
      aliasFor: row['alias_for'] as String?,
      country: row['country'] as String?,
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
      lastName: row['last_name'] as String?,
      lastSeen: row['last_seen'] as DateTime?,
    );
  }
}

class MobileDevice {
  final String manufacturer;
  final int userId;
  final String osLocale;
  final String model;
  final int configurationId;
  final String deviceIdentifier;
  final String appVersion;
  final String osName;
  final String? notificationToken;
  final DateTime lastSeen;
  final int id;
  final String appLanguage;
  final DateTime created;
  final DateTime? notificationTokenUpdated;
  final String osVersion;

  MobileDevice({
    required this.manufacturer,
    required this.userId,
    required this.osLocale,
    required this.model,
    required this.configurationId,
    required this.deviceIdentifier,
    required this.appVersion,
    required this.osName,
    this.notificationToken,
    required this.lastSeen,
    required this.id,
    required this.appLanguage,
    required this.created,
    this.notificationTokenUpdated,
    required this.osVersion,
  });

  static MobileDevice fromRow(Map<String, dynamic> row) {
    return MobileDevice(
      manufacturer: row['manufacturer']! as String,
      userId: row['user_id']! as int,
      osLocale: row['os_locale']! as String,
      model: row['model']! as String,
      configurationId: row['configuration_id']! as int,
      deviceIdentifier: row['device_identifier']! as String,
      appVersion: row['app_version']! as String,
      osName: row['os_name']! as String,
      notificationToken: row['notification_token'] as String?,
      lastSeen: row['last_seen']! as DateTime,
      id: row['id']! as int,
      appLanguage: row['app_language']! as String,
      created: row['created']! as DateTime,
      notificationTokenUpdated: row['notification_token_updated'] as DateTime?,
      osVersion: row['os_version']! as String,
    );
  }
}
