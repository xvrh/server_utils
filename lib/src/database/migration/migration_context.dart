import 'package:server_utils/src/database/connection_options.dart';

import '../postgres.dart';
import '../utils.dart';
import 'package:postgres/postgres.dart';

class MigrationContext {
  final PostgresClient client;
  final PostgreSQLConnection? connection;

  MigrationContext._(this.client, this.connection);

  static MigrationContext closed(PostgresClient client) {
    return MigrationContext._(client, null);
  }

  static Future<MigrationContext> open(PostgresClient client) async {
    var connection = connectionFromOptions(client.connectionOptions);
    await connection.open();
    return MigrationContext._(client, connection);
  }

  static Future<MigrationContext> openFromJson(Map<String, dynamic> json) {
    var dataPath = json['dataPath']! as String;
    var connectionOptions = ConnectionOptions.fromJson(
        json['connectionOptions']! as Map<String, dynamic>);

    return open(PostgresClient(connectionOptions, dataPath: dataPath));
  }

  Map<String, dynamic> toJson() => {
        'dataPath': client.dataPath,
        'connectionOptions': connectionOptions.toJson(),
      };

  ConnectionOptions get connectionOptions => client.connectionOptions;
}
