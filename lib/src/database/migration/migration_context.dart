import 'package:postgres_pool/postgres_pool.dart';
import '../postgres.dart';
import '../utils.dart';

class MigrationContext {
  final PostgresClient client;
  final PostgreSQLConnection? connection;

  MigrationContext._(this.client, this.connection);

  static MigrationContext closed(PostgresClient client) {
    return MigrationContext._(client, null);
  }

  static Future<MigrationContext> open(PostgresClient client) async {
    var connection = connectionFromEndpoint(client.endpoint);
    await connection.open();
    return MigrationContext._(client, connection);
  }

  static Future<MigrationContext> openFromJson(Map<String, dynamic> json) {
    var dataPath = json['dataPath']! as String;
    var connectionOptions = PgEndpoint.parse(json['endpoint']! as String);

    return open(PostgresClient(connectionOptions, dataPath: dataPath));
  }

  Map<String, dynamic> toJson() => {
        'dataPath': client.dataPath,
        'endpoint': endpoint.toString(),
      };

  PgEndpoint get endpoint => client.endpoint;
}
