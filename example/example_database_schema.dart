// GENERATED-FILE
class Page {
  final int id;
  final String? code;
  final dynamic title;
  final dynamic title2;
  final dynamic? title3;
  final dynamic body;
  final String? pageType;

  Page({
    required this.id,
    this.code,
    required this.title,
    required this.title2,
    this.title3,
    required this.body,
    this.pageType,
  });

  static Page fromRow(Map<String, dynamic> row) {
    return Page(
      id: row['id']! as int,
      code: row['code'] as String?,
      title: row['title']! as dynamic,
      title2: row['title2']! as dynamic,
      title3: row['title3'] as dynamic?,
      body: row['body']! as dynamic,
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
  final String code;
  final String codeIso3;
  final String currency;
  final double latitude;
  final double longitude;
  final int phoneCode;

  Country({
    required this.code,
    required this.codeIso3,
    required this.currency,
    required this.latitude,
    required this.longitude,
    required this.phoneCode,
  });

  static Country fromRow(Map<String, dynamic> row) {
    return Country(
      code: row['code']! as String,
      codeIso3: row['code_iso3']! as String,
      currency: row['currency']! as String,
      latitude: row['latitude']! as double,
      longitude: row['longitude']! as double,
      phoneCode: row['phone_code']! as int,
    );
  }
}

class Timezone {
  final String name;
  final String? country;
  final String? aliasFor;
  final String latLong;

  Timezone({
    required this.name,
    this.country,
    this.aliasFor,
    required this.latLong,
  });

  static Timezone fromRow(Map<String, dynamic> row) {
    return Timezone(
      name: row['name']! as String,
      country: row['country'] as String?,
      aliasFor: row['alias_for'] as String?,
      latLong: row['lat_long']! as String,
    );
  }
}

class AppRole {
  final String code;
  final int index;
  final String name;
  final String description;

  AppRole({
    required this.code,
    required this.index,
    required this.name,
    required this.description,
  });

  static AppRole fromRow(Map<String, dynamic> row) {
    return AppRole(
      code: row['code']! as String,
      index: row['index']! as int,
      name: row['name']! as String,
      description: row['description']! as String,
    );
  }
}

class AppUser {
  final int id;
  final String role;
  final String email;
  final DateTime created;
  final DateTime? lastSeen;
  final String countryCode;
  final int configurationId;
  final String? eulaVersion;
  final String? firstName;
  final String? middleName;
  final String? lastName;

  AppUser({
    required this.id,
    required this.role,
    required this.email,
    required this.created,
    this.lastSeen,
    required this.countryCode,
    required this.configurationId,
    this.eulaVersion,
    this.firstName,
    this.middleName,
    this.lastName,
  });

  static AppUser fromRow(Map<String, dynamic> row) {
    return AppUser(
      id: row['id']! as int,
      role: row['role']! as String,
      email: row['email']! as String,
      created: row['created']! as DateTime,
      lastSeen: row['last_seen'] as DateTime?,
      countryCode: row['country_code']! as String,
      configurationId: row['configuration_id']! as int,
      eulaVersion: row['eula_version'] as String?,
      firstName: row['first_name'] as String?,
      middleName: row['middle_name'] as String?,
      lastName: row['last_name'] as String?,
    );
  }
}

class MobileDevice {
  final int id;
  final int userId;
  final DateTime created;
  final DateTime lastSeen;
  final String deviceIdentifier;
  final String? notificationToken;
  final DateTime? notificationTokenUpdated;
  final String osName;
  final String osVersion;
  final String osLocale;
  final String manufacturer;
  final String model;
  final String appVersion;
  final String appLanguage;
  final int configurationId;

  MobileDevice({
    required this.id,
    required this.userId,
    required this.created,
    required this.lastSeen,
    required this.deviceIdentifier,
    this.notificationToken,
    this.notificationTokenUpdated,
    required this.osName,
    required this.osVersion,
    required this.osLocale,
    required this.manufacturer,
    required this.model,
    required this.appVersion,
    required this.appLanguage,
    required this.configurationId,
  });

  static MobileDevice fromRow(Map<String, dynamic> row) {
    return MobileDevice(
      id: row['id']! as int,
      userId: row['user_id']! as int,
      created: row['created']! as DateTime,
      lastSeen: row['last_seen']! as DateTime,
      deviceIdentifier: row['device_identifier']! as String,
      notificationToken: row['notification_token'] as String?,
      notificationTokenUpdated: row['notification_token_updated'] as DateTime?,
      osName: row['os_name']! as String,
      osVersion: row['os_version']! as String,
      osLocale: row['os_locale']! as String,
      manufacturer: row['manufacturer']! as String,
      model: row['model']! as String,
      appVersion: row['app_version']! as String,
      appLanguage: row['app_language']! as String,
      configurationId: row['configuration_id']! as int,
    );
  }
}
