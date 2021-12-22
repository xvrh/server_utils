// GENERATED-FILE
class Page {
  final dynamic body;
  final String? code;
  final int id;
  final dynamic title2;
  final dynamic title;
  final String? pageType;

  Page({
    required this.body,
    this.code,
    required this.id,
    required this.title2,
    required this.title,
    this.pageType,
  });

  static Page fromRow(Map<String, dynamic> row) {
    return Page(
      body: row['body']! as dynamic,
      code: row['code'] as String?,
      id: row['id']! as int,
      title2: row['title2']! as dynamic,
      title: row['title']! as dynamic,
      pageType: row['page_type'] as String?,
    );
  }
}

class AppConfiguration {
  final bool? enableLogs;
  final int id;

  AppConfiguration({
    this.enableLogs,
    required this.id,
  });

  static AppConfiguration fromRow(Map<String, dynamic> row) {
    return AppConfiguration(
      enableLogs: row['enable_logs'] as bool?,
      id: row['id']! as int,
    );
  }
}

class Country {
  final double longitude;
  final String codeIso3;
  final String currency;
  final String code;
  final double latitude;
  final int phoneCode;

  Country({
    required this.longitude,
    required this.codeIso3,
    required this.currency,
    required this.code,
    required this.latitude,
    required this.phoneCode,
  });

  static Country fromRow(Map<String, dynamic> row) {
    return Country(
      longitude: row['longitude']! as double,
      codeIso3: row['code_iso3']! as String,
      currency: row['currency']! as String,
      code: row['code']! as String,
      latitude: row['latitude']! as double,
      phoneCode: row['phone_code']! as int,
    );
  }
}

class Timezone {
  final String name;
  final String latLong;
  final String? aliasFor;
  final String? country;

  Timezone({
    required this.name,
    required this.latLong,
    this.aliasFor,
    this.country,
  });

  static Timezone fromRow(Map<String, dynamic> row) {
    return Timezone(
      name: row['name']! as String,
      latLong: row['lat_long']! as String,
      aliasFor: row['alias_for'] as String?,
      country: row['country'] as String?,
    );
  }
}

class AppRole {
  final String description;
  final String code;
  final String name;
  final int index;

  AppRole({
    required this.description,
    required this.code,
    required this.name,
    required this.index,
  });

  static AppRole fromRow(Map<String, dynamic> row) {
    return AppRole(
      description: row['description']! as String,
      code: row['code']! as String,
      name: row['name']! as String,
      index: row['index']! as int,
    );
  }
}

class AppUser {
  final String? middleName;
  final String role;
  final String? lastName;
  final DateTime? lastSeen;
  final String? eulaVersion;
  final String countryCode;
  final int id;
  final DateTime created;
  final String? firstName;
  final int configurationId;
  final String email;

  AppUser({
    this.middleName,
    required this.role,
    this.lastName,
    this.lastSeen,
    this.eulaVersion,
    required this.countryCode,
    required this.id,
    required this.created,
    this.firstName,
    required this.configurationId,
    required this.email,
  });

  static AppUser fromRow(Map<String, dynamic> row) {
    return AppUser(
      middleName: row['middle_name'] as String?,
      role: row['role']! as String,
      lastName: row['last_name'] as String?,
      lastSeen: row['last_seen'] as DateTime?,
      eulaVersion: row['eula_version'] as String?,
      countryCode: row['country_code']! as String,
      id: row['id']! as int,
      created: row['created']! as DateTime,
      firstName: row['first_name'] as String?,
      configurationId: row['configuration_id']! as int,
      email: row['email']! as String,
    );
  }
}

class MobileDevice {
  final int id;
  final DateTime lastSeen;
  final String osVersion;
  final DateTime? notificationTokenUpdated;
  final DateTime created;
  final String appLanguage;
  final String osName;
  final String? notificationToken;
  final String appVersion;
  final String deviceIdentifier;
  final int configurationId;
  final String model;
  final String osLocale;
  final int userId;
  final String manufacturer;

  MobileDevice({
    required this.id,
    required this.lastSeen,
    required this.osVersion,
    this.notificationTokenUpdated,
    required this.created,
    required this.appLanguage,
    required this.osName,
    this.notificationToken,
    required this.appVersion,
    required this.deviceIdentifier,
    required this.configurationId,
    required this.model,
    required this.osLocale,
    required this.userId,
    required this.manufacturer,
  });

  static MobileDevice fromRow(Map<String, dynamic> row) {
    return MobileDevice(
      id: row['id']! as int,
      lastSeen: row['last_seen']! as DateTime,
      osVersion: row['os_version']! as String,
      notificationTokenUpdated: row['notification_token_updated'] as DateTime?,
      created: row['created']! as DateTime,
      appLanguage: row['app_language']! as String,
      osName: row['os_name']! as String,
      notificationToken: row['notification_token'] as String?,
      appVersion: row['app_version']! as String,
      deviceIdentifier: row['device_identifier']! as String,
      configurationId: row['configuration_id']! as int,
      model: row['model']! as String,
      osLocale: row['os_locale']! as String,
      userId: row['user_id']! as int,
      manufacturer: row['manufacturer']! as String,
    );
  }
}
