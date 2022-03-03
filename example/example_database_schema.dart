// GENERATED-FILE
import 'package:server_utils/database.dart';

class AppRole implements EnumLike {
  static const user = AppRole._('USER');
  static const admin = AppRole._('ADMIN');

  static const values = [
    user,
    admin,
  ];

  final String value;

  const AppRole._(this.value);

  factory AppRole(String value) => values.firstWhere((e) => e.value == value);

  factory AppRole.fromJson(String json) =>
      values.firstWhere((e) => e.value == json, orElse: () => AppRole._(json));

  String toJson() => value;

  bool get isUnknown => values.every((v) => v.value != value);

  @override
  String toString() => value;
}

class ConsentType implements EnumLike {
  static const privacyPolicy = ConsentType._('privacy_policy');
  static const termsOfUse = ConsentType._('terms_of_use');

  static const values = [
    privacyPolicy,
    termsOfUse,
  ];

  final String value;

  const ConsentType._(this.value);

  factory ConsentType(String value) =>
      values.firstWhere((e) => e.value == value);

  factory ConsentType.fromJson(String json) => values
      .firstWhere((e) => e.value == json, orElse: () => ConsentType._(json));

  String toJson() => value;

  bool get isUnknown => values.every((v) => v.value != value);

  @override
  String toString() => value;
}

class CmsPage {
  static final table = TableDefinition(
    'cms_page',
    [
      ColumnDefinition('id',
          type: DataType.integer, isNullable: false, isPrimaryKey: true),
      ColumnDefinition('code', type: DataType.text),
      ColumnDefinition('title',
          type: DataType.jsonb, domain: 'translated_text', isNullable: false),
      ColumnDefinition('title2', type: DataType.jsonb, isNullable: false),
      ColumnDefinition('title3', type: DataType.jsonb),
      ColumnDefinition('body',
          type: DataType.jsonb, domain: 'translated_text', isNullable: false),
      ColumnDefinition('page_type', type: DataType.text),
    ],
  );

  static final columns = _CmsPageColumns();

  final int id;
  final String? code;
  final Object title;
  final Object title2;
  final Object? title3;
  final Object body;
  final String? pageType;

  CmsPage({
    required this.id,
    this.code,
    required this.title,
    required this.title2,
    this.title3,
    required this.body,
    this.pageType,
  });

  factory CmsPage.fromRow(Map<String, dynamic> row) {
    return CmsPage(
      id: row['id']! as int,
      code: row['code'] as String?,
      title: row['title']! as Object,
      title2: row['title2']! as Object,
      title3: row['title3'] as Object?,
      body: row['body']! as Object,
      pageType: row['page_type'] as String?,
    );
  }

  factory CmsPage.fromJson(Map<String, Object?> json) {
    return CmsPage(
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

  CmsPage copyWith({
    int? id,
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
    return CmsPage(
      id: id ?? this.id,
      code: (clearCode ?? false) ? null : code ?? this.code,
      title: title ?? this.title,
      title2: title2 ?? this.title2,
      title3: (clearTitle3 ?? false) ? null : title3 ?? this.title3,
      body: body ?? this.body,
      pageType: (clearPageType ?? false) ? null : pageType ?? this.pageType,
    );
  }
}

class _CmsPageColumns {
  final id = Column<CmsPage>('id');
  final code = Column<CmsPage>('code');
  final title = Column<CmsPage>('title');
  final title2 = Column<CmsPage>('title2');
  final title3 = Column<CmsPage>('title3');
  final body = Column<CmsPage>('body');
  final pageType = Column<CmsPage>('page_type');
}

class Country {
  static final table = TableDefinition(
    'country',
    [
      ColumnDefinition('code',
          type: DataType.characterVarying,
          isNullable: false,
          isPrimaryKey: true),
      ColumnDefinition('code_iso3',
          type: DataType.characterVarying, isNullable: false),
      ColumnDefinition('currency',
          type: DataType.characterVarying, isNullable: false),
      ColumnDefinition('latitude',
          type: DataType.doublePrecision, isNullable: false),
      ColumnDefinition('longitude',
          type: DataType.doublePrecision, isNullable: false),
      ColumnDefinition('phone_code', type: DataType.integer, isNullable: false),
    ],
  );

  static final columns = _CountryColumns();

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

  Country copyWith({
    String? code,
    String? codeIso3,
    String? currency,
    double? latitude,
    double? longitude,
    int? phoneCode,
  }) {
    return Country(
      code: code ?? this.code,
      codeIso3: codeIso3 ?? this.codeIso3,
      currency: currency ?? this.currency,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneCode: phoneCode ?? this.phoneCode,
    );
  }
}

class _CountryColumns {
  final code = Column<Country>('code');
  final codeIso3 = Column<Country>('code_iso3');
  final currency = Column<Country>('currency');
  final latitude = Column<Country>('latitude');
  final longitude = Column<Country>('longitude');
  final phoneCode = Column<Country>('phone_code');
}

class Timezone {
  static final table = TableDefinition(
    'timezone',
    [
      ColumnDefinition('name',
          type: DataType.text, isNullable: false, isPrimaryKey: true),
      ColumnDefinition('country',
          type: DataType.characterVarying, foreignTable: 'country'),
      ColumnDefinition('alias_for',
          type: DataType.text, foreignTable: 'timezone'),
      ColumnDefinition('lat_long', type: DataType.text, isNullable: false),
    ],
  );

  static final columns = _TimezoneColumns();

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

  Timezone copyWith({
    String? name,
    String? country,
    bool? clearCountry,
    String? aliasFor,
    bool? clearAliasFor,
    String? latLong,
  }) {
    return Timezone(
      name: name ?? this.name,
      country: (clearCountry ?? false) ? null : country ?? this.country,
      aliasFor: (clearAliasFor ?? false) ? null : aliasFor ?? this.aliasFor,
      latLong: latLong ?? this.latLong,
    );
  }
}

class _TimezoneColumns {
  final name = Column<Timezone>('name');
  final country = Column<Timezone>('country');
  final aliasFor = Column<Timezone>('alias_for');
  final latLong = Column<Timezone>('lat_long');
}

class AppUser {
  static final table = TableDefinition(
    'app_user',
    [
      ColumnDefinition('id',
          type: DataType.integer, isNullable: false, isPrimaryKey: true),
      ColumnDefinition('role', type: DataType.text, isNullable: false),
      ColumnDefinition('email', type: DataType.text, isNullable: false),
      ColumnDefinition('created',
          type: DataType.timestampWithTimeZone, isNullable: false),
      ColumnDefinition('last_seen', type: DataType.timestampWithTimeZone),
      ColumnDefinition('country_code',
          type: DataType.characterVarying,
          isNullable: false,
          foreignTable: 'country'),
      ColumnDefinition('configuration_id',
          type: DataType.integer,
          isNullable: false,
          foreignTable: 'app_configuration'),
      ColumnDefinition('eula_version', type: DataType.text),
      ColumnDefinition('first_name', type: DataType.text),
      ColumnDefinition('middle_name', type: DataType.text),
      ColumnDefinition('last_name', type: DataType.text),
    ],
  );

  static final columns = _AppUserColumns();

  final int id;
  final AppRole role;
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
      role: AppRole(row['role']! as String),
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
      role: AppRole.fromJson(json['role']! as String),
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
      'role': role.toJson(),
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

  AppUser copyWith({
    int? id,
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
    return AppUser(
      id: id ?? this.id,
      role: role ?? this.role,
      email: email ?? this.email,
      created: created ?? this.created,
      lastSeen: (clearLastSeen ?? false) ? null : lastSeen ?? this.lastSeen,
      countryCode: countryCode ?? this.countryCode,
      configurationId: configurationId ?? this.configurationId,
      eulaVersion:
          (clearEulaVersion ?? false) ? null : eulaVersion ?? this.eulaVersion,
      firstName: (clearFirstName ?? false) ? null : firstName ?? this.firstName,
      middleName:
          (clearMiddleName ?? false) ? null : middleName ?? this.middleName,
      lastName: (clearLastName ?? false) ? null : lastName ?? this.lastName,
    );
  }
}

class _AppUserColumns {
  final id = Column<AppUser>('id');
  final role = Column<AppUser>('role');
  final email = Column<AppUser>('email');
  final created = Column<AppUser>('created');
  final lastSeen = Column<AppUser>('last_seen');
  final countryCode = Column<AppUser>('country_code');
  final configurationId = Column<AppUser>('configuration_id');
  final eulaVersion = Column<AppUser>('eula_version');
  final firstName = Column<AppUser>('first_name');
  final middleName = Column<AppUser>('middle_name');
  final lastName = Column<AppUser>('last_name');
}

class AppConfiguration {
  static final table = TableDefinition(
    'app_configuration',
    [
      ColumnDefinition('id',
          type: DataType.integer, isNullable: false, isPrimaryKey: true),
      ColumnDefinition('enable_logs', type: DataType.boolean),
    ],
  );

  static final columns = _AppConfigurationColumns();

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

  AppConfiguration copyWith({
    int? id,
    bool? enableLogs,
    bool? clearEnableLogs,
  }) {
    return AppConfiguration(
      id: id ?? this.id,
      enableLogs:
          (clearEnableLogs ?? false) ? null : enableLogs ?? this.enableLogs,
    );
  }
}

class _AppConfigurationColumns {
  final id = Column<AppConfiguration>('id');
  final enableLogs = Column<AppConfiguration>('enable_logs');
}

class MobileDevice {
  static final table = TableDefinition(
    'mobile_device',
    [
      ColumnDefinition('id',
          type: DataType.integer, isNullable: false, isPrimaryKey: true),
      ColumnDefinition('user_id',
          type: DataType.integer, isNullable: false, foreignTable: 'app_user'),
      ColumnDefinition('created',
          type: DataType.timestampWithTimeZone, isNullable: false),
      ColumnDefinition('last_seen',
          type: DataType.timestampWithTimeZone, isNullable: false),
      ColumnDefinition('device_identifier',
          type: DataType.text, isNullable: false),
      ColumnDefinition('notification_token', type: DataType.text),
      ColumnDefinition('notification_token_updated',
          type: DataType.timestampWithTimeZone),
      ColumnDefinition('os_name', type: DataType.text, isNullable: false),
      ColumnDefinition('os_version', type: DataType.text, isNullable: false),
      ColumnDefinition('os_locale', type: DataType.text, isNullable: false),
      ColumnDefinition('manufacturer', type: DataType.text, isNullable: false),
      ColumnDefinition('model', type: DataType.text, isNullable: false),
      ColumnDefinition('app_version', type: DataType.text, isNullable: false),
      ColumnDefinition('app_language', type: DataType.text, isNullable: false),
      ColumnDefinition('configuration_id',
          type: DataType.integer,
          isNullable: false,
          foreignTable: 'app_configuration'),
    ],
  );

  static final columns = _MobileDeviceColumns();

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

  MobileDevice copyWith({
    int? id,
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
    return MobileDevice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      created: created ?? this.created,
      lastSeen: lastSeen ?? this.lastSeen,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      notificationToken: (clearNotificationToken ?? false)
          ? null
          : notificationToken ?? this.notificationToken,
      notificationTokenUpdated: (clearNotificationTokenUpdated ?? false)
          ? null
          : notificationTokenUpdated ?? this.notificationTokenUpdated,
      osName: osName ?? this.osName,
      osVersion: osVersion ?? this.osVersion,
      osLocale: osLocale ?? this.osLocale,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      appVersion: appVersion ?? this.appVersion,
      appLanguage: appLanguage ?? this.appLanguage,
      configurationId: configurationId ?? this.configurationId,
    );
  }
}

class _MobileDeviceColumns {
  final id = Column<MobileDevice>('id');
  final userId = Column<MobileDevice>('user_id');
  final created = Column<MobileDevice>('created');
  final lastSeen = Column<MobileDevice>('last_seen');
  final deviceIdentifier = Column<MobileDevice>('device_identifier');
  final notificationToken = Column<MobileDevice>('notification_token');
  final notificationTokenUpdated =
      Column<MobileDevice>('notification_token_updated');
  final osName = Column<MobileDevice>('os_name');
  final osVersion = Column<MobileDevice>('os_version');
  final osLocale = Column<MobileDevice>('os_locale');
  final manufacturer = Column<MobileDevice>('manufacturer');
  final model = Column<MobileDevice>('model');
  final appVersion = Column<MobileDevice>('app_version');
  final appLanguage = Column<MobileDevice>('app_language');
  final configurationId = Column<MobileDevice>('configuration_id');
}

class Consent {
  static final table = TableDefinition(
    'consent',
    [
      ColumnDefinition('id',
          type: DataType.integer, isNullable: false, isPrimaryKey: true),
      ColumnDefinition('type', type: DataType.text, isNullable: false),
    ],
  );

  static final columns = _ConsentColumns();

  final int id;
  final ConsentType type;

  Consent({
    required this.id,
    required this.type,
  });

  factory Consent.fromRow(Map<String, dynamic> row) {
    return Consent(
      id: row['id']! as int,
      type: ConsentType(row['type']! as String),
    );
  }

  factory Consent.fromJson(Map<String, Object?> json) {
    return Consent(
      id: (json['id']! as num).toInt(),
      type: ConsentType.fromJson(json['type']! as String),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
    };
  }

  Consent copyWith({
    int? id,
    ConsentType? type,
  }) {
    return Consent(
      id: id ?? this.id,
      type: type ?? this.type,
    );
  }
}

class _ConsentColumns {
  final id = Column<Consent>('id');
  final type = Column<Consent>('type');
}
