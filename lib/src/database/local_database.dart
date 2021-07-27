import 'dart:async';
import 'package:postgres_pool/postgres_pool.dart';
import 'package:postgres/postgres.dart';
import 'database.dart';
import 'connection_options.dart';
import 'database_io.dart';
import 'postgres.dart';
import 'utils.dart';

class LocalDatabase {
  final Postgres postgres;
  final String name;
  final ConnectionOptions connectionOptions;
  final PostgresClient _client;

  LocalDatabase(this.postgres, this.connectionOptions)
      : name = connectionOptions.database!,
        _client = postgres.clientFromOptions(connectionOptions);

  PostgreSQLConnection createConnection() {
    return connectionFromOptions(connectionOptions);
  }

  PostgresClient get client => _client;

  Future<void> drop() {
    return postgres.client().dropDatabase(name);
  }

  Future<T> use<T>(FutureOr<T> Function(Database) callback) async {
    var connection = createConnection();
    await connection.open();
    try {
      return await callback(DatabaseIO(connection));
    } finally {
      await connection.close();
    }
  }
}
