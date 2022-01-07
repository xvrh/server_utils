import 'dart:io';

import 'package:server_utils/database.dart';
import 'package:test/test.dart';
import '../../example/example_database.dart';

final isCI = Platform.environment['CI'] != null;

class DatabaseTestUtils {
  late LocalDatabase database;
  late Postgres postgres;
  PostgresServer? postgresServer;

  DatabaseTestUtils() {
    setUpAll(() async {
      postgres = exampleDatabaseServer;
    });

    setUp(() async {
      database = await postgres.createDatabase();
    });

    tearDown(() async {
      await database.drop();
    });

    tearDownAll(() async {
      await postgresServer?.stop();
    });
  }
}
