// GENERATED-FILE
class Page {
  final int id;
  final String? code;
  final Object title;
  final Object title2;
  final Object? title3;
  final Object body;
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

  factory Page.fromRow(Map<String, dynamic> row) {
    return Page(
      id: row['id']! as int,
      code: row['code'] as String?,
      title: row['title']! as Object,
      title2: row['title2']! as Object,
      title3: row['title3'] as Object?,
      body: row['body']! as Object,
      pageType: row['page_type'] as String?,
    );
  }

  factory Page.fromJson(Map<String, Object?> json) {
    return Page(
      id: (json['id']! as num).toInt(),
      code: json['code'] as String?,
      title: json['title']!,
      title2: json['title2']!,
      title3: json['title3'],
      body: json['body']!,
      pageType: json['pageType'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'title2': title2,
      'title3': title3,
      'body': body,
      'pageType': pageType,
    };
  }
}

class AppConfiguration {
  final int id;
  final bool? enableLogs;

  AppConfiguration({
    required this.id,
    this.enableLogs,
  });

  factory AppConfiguration.fromRow(Map<String, dynamic> row) {
    return AppConfiguration(
      id: row['id']! as int,
      enableLogs: row['enable_logs'] as bool?,
    );
  }

  factory AppConfiguration.fromJson(Map<String, Object?> json) {
    return AppConfiguration(
      id: (json['id']! as num).toInt(),
      enableLogs: json['enableLogs'] as bool?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'enableLogs': enableLogs,
    };
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

  factory Country.fromRow(Map<String, dynamic> row) {
    return Country(
      code: row['code']! as String,
      codeIso3: row['code_iso3']! as String,
      currency: row['currency']! as String,
      latitude: row['latitude']! as double,
      longitude: row['longitude']! as double,
      phoneCode: row['phone_code']! as int,
    );
  }

  factory Country.fromJson(Map<String, Object?> json) {
    return Country(
      code: json['code']! as String,
      codeIso3: json['codeIso3']! as String,
      currency: json['currency']! as String,
      latitude: (json['latitude']! as num).toDouble(),
      longitude: (json['longitude']! as num).toDouble(),
      phoneCode: (json['phoneCode']! as num).toInt(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'code': code,
      'codeIso3': codeIso3,
      'currency': currency,
      'latitude': latitude,
      'longitude': longitude,
      'phoneCode': phoneCode,
    };
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

  factory Timezone.fromRow(Map<String, dynamic> row) {
    return Timezone(
      name: row['name']! as String,
      country: row['country'] as String?,
      aliasFor: row['alias_for'] as String?,
      latLong: row['lat_long']! as String,
    );
  }

  factory Timezone.fromJson(Map<String, Object?> json) {
    return Timezone(
      name: json['name']! as String,
      country: json['country'] as String?,
      aliasFor: json['aliasFor'] as String?,
      latLong: json['latLong']! as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'country': country,
      'aliasFor': aliasFor,
      'latLong': latLong,
    };
  }
}

class AppRole {
  static final admin = AppRole(
    code: 'ADMIN',
    index: 100,
    name: 'Admin',
    description: '',
  );
  static final user = AppRole(
    code: 'USER',
    index: 0,
    name: 'User',
    description: '',
  );

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

  factory AppRole.fromRow(Map<String, dynamic> row) {
    return AppRole(
      code: row['code']! as String,
      index: row['index']! as int,
      name: row['name']! as String,
      description: row['description']! as String,
    );
  }

  factory AppRole.fromJson(Map<String, Object?> json) {
    return AppRole(
      code: json['code']! as String,
      index: (json['index']! as num).toInt(),
      name: json['name']! as String,
      description: json['description']! as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'code': code,
      'index': index,
      'name': name,
      'description': description,
    };
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

  factory AppUser.fromRow(Map<String, dynamic> row) {
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

  factory AppUser.fromJson(Map<String, Object?> json) {
    return AppUser(
      id: (json['id']! as num).toInt(),
      role: json['role']! as String,
      email: json['email']! as String,
      created: DateTime.parse(json['created']! as String),
      lastSeen: DateTime.tryParse(json['lastSeen'] as String? ?? ''),
      countryCode: json['countryCode']! as String,
      configurationId: (json['configurationId']! as num).toInt(),
      eulaVersion: json['eulaVersion'] as String?,
      firstName: json['firstName'] as String?,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'role': role,
      'email': email,
      'created': created.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
      'countryCode': countryCode,
      'configurationId': configurationId,
      'eulaVersion': eulaVersion,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
    };
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

  factory MobileDevice.fromRow(Map<String, dynamic> row) {
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

  factory MobileDevice.fromJson(Map<String, Object?> json) {
    return MobileDevice(
      id: (json['id']! as num).toInt(),
      userId: (json['userId']! as num).toInt(),
      created: DateTime.parse(json['created']! as String),
      lastSeen: DateTime.parse(json['lastSeen']! as String),
      deviceIdentifier: json['deviceIdentifier']! as String,
      notificationToken: json['notificationToken'] as String?,
      notificationTokenUpdated:
          DateTime.tryParse(json['notificationTokenUpdated'] as String? ?? ''),
      osName: json['osName']! as String,
      osVersion: json['osVersion']! as String,
      osLocale: json['osLocale']! as String,
      manufacturer: json['manufacturer']! as String,
      model: json['model']! as String,
      appVersion: json['appVersion']! as String,
      appLanguage: json['appLanguage']! as String,
      configurationId: (json['configurationId']! as num).toInt(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'userId': userId,
      'created': created.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
      'deviceIdentifier': deviceIdentifier,
      'notificationToken': notificationToken,
      'notificationTokenUpdated': notificationTokenUpdated?.toIso8601String(),
      'osName': osName,
      'osVersion': osVersion,
      'osLocale': osLocale,
      'manufacturer': manufacturer,
      'model': model,
      'appVersion': appVersion,
      'appLanguage': appLanguage,
      'configurationId': configurationId,
    };
  }
}
