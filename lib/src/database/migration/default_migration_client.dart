import 'dart:io';

import 'package:postgres_pool/postgres_pool.dart';
import 'package:server_utils/src/database/migration/migration_client.dart';
import '../postgres.dart';
import '../utils.dart';
import '../../utils/escape_dart_string.dart';

class PostgresMigrationClient implements MigrationClient {
  final PostgresClient client;

  PostgresMigrationClient(this.client);

  @override
  Future<void> executeFile(File file) => client.executeFile(file);

  @override
  Future<T> runConnection<T>(
      Future<T> Function(PostgreSQLExecutionContext p1) callback) async {
    var connection = connectionFromEndpoint(client.endpoint);
    await connection.open();
    try {
      return await callback(connection);
    } finally {
      await connection.close();
    }
  }

  @override
  MigrationContextCode migrationContext() {
    return MigrationContextCode(
      "import 'package:server_utils/src/database/migration/default_migration_client.dart' as _mig;",
      '''
await _mig.PostgresMigrationContext.open(
  dataPath: ${escapeDartString(client.dataPath)},
  endpoint: ${escapeDartString(client.endpoint.toString())},
);
''',
    );
  }
}

class PostgresMigrationContext implements MigrationContext {
  final PostgresClient client;

  @override
  final PostgreSQLConnection connection;

  PostgresMigrationContext._(this.client, this.connection);

  static Future<PostgresMigrationContext> open(
      {required String dataPath, required String endpoint}) async {
    var pgEndpoint = PgEndpoint.parse(endpoint);
    var connection = connectionFromEndpoint(pgEndpoint);
    await connection.open();
    return PostgresMigrationContext._(
        PostgresClient(pgEndpoint, dataPath: dataPath), connection);
  }

  @override
  Future<void> close() async {
    await connection.close();
  }

  @override
  Future<void> execute(String script) => client.execute(script);

  @override
  Future<void> executeFile(File file) => client.executeFile(file);
}
