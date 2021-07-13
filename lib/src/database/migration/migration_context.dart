import 'package:database/postgres.dart';
import 'package:database/src/utils.dart';
import 'package:postgres/postgres.dart';

class MigrationContext {
  final PostgresClient client;
  final PostgreSQLConnection? connection;

  MigrationContext._(this.client, this.connection);

  static MigrationContext closed(PostgresClient client) {
    return MigrationContext._(client, null);
  }

  static Future<MigrationContext> open(PostgresClient client) async {
    PostgreSQLConnection connection =
        connectionFromOptions(client.connectionOptions);
    await connection.open();
    return MigrationContext._(client, connection);
  }

  static Future<MigrationContext> openFromJson(Map<String, dynamic> json) {
    var binaries = PostgresBinaries.fromJson(json['binaries']);
    var connectionOptions =
        ConnectionOptions.fromJson(json['connectionOptions']);

    return open(PostgresClient(connectionOptions, binaries: binaries));
  }

  Map<String, dynamic> toJson() => {
        'binaries': client.binaries.toJson(),
        'connectionOptions': connectionOptions.toJson(),
      };

  ConnectionOptions get connectionOptions => client.connectionOptions;

  //TODO(xha): accéder aux paramètres
}
