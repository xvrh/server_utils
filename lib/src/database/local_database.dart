import 'dart:async';
import 'package:postgres_pool/postgres_pool.dart';
import 'database.dart';
import 'database_io.dart';
import 'postgres.dart';
import 'utils.dart';

class LocalDatabase {
  final Postgres postgres;
  final String name;
  final PgEndpoint endpoint;
  final PostgresClient _client;

  LocalDatabase(this.postgres, this.endpoint)
      : name = endpoint.database,
        _client = postgres.clientFromEndpoint(endpoint);

  PostgreSQLConnection createConnection() {
    return connectionFromEndpoint(endpoint);
  }

  PostgresClient get client => _client;

  Future<void> drop() {
    return postgres.client().dropDatabase(name);
  }

  Future<T> use<T>(FutureOr<T> Function(Database) callback) async {
    return useConnection((connection) => callback(DatabaseIO(connection)));
  }

  Future<T> useConnection<T>(
      FutureOr<T> Function(PostgreSQLConnection) callback) async {
    return useEndpoint(endpoint, callback);
  }
}
