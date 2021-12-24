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
      if (isCI) {
        var tempPostgres = Postgres(Postgres.temporaryPath);
        var postgresServerLocal = postgresServer = await tempPostgres.server();
        var postgresWithPort =
            tempPostgres.copyWith(port: postgresServerLocal.port);
        postgres = postgresWithPort;
      } else {
        postgres = exampleDatabaseSuperUser;
      }
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
