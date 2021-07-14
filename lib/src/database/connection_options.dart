class ConnectionOptions {
  static const defaultPort = 5432;

  final String? hostname;
  final int? port;
  final String? user, password;
  final String? database;

  ConnectionOptions(
      {this.hostname,
      this.port,
      required this.user,
      required this.password,
      required this.database});

  factory ConnectionOptions.fromJson(Map<String, dynamic> json) =>
      ConnectionOptions(
        hostname: json['hostname'] as String?,
        port: json['port'] as int?,
        user: json['user'] as String?,
        password: json['password'] as String?,
        database: json['database']! as String,
      );

  Map<String, dynamic> toJson() => {
        'hostname': hostname,
        'port': port,
        'user': user,
        'password': password,
        'database': database,
      };

  ConnectionOptions copyWith(
      {String? hostname,
      int? port,
      String? user,
      String? password,
      String? database}) {
    return ConnectionOptions(
      hostname: hostname ?? this.hostname,
      port: port ?? this.port,
      user: user ?? this.user,
      password: password ?? this.password,
      database: database ?? this.database,
    );
  }
}
