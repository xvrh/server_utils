import 'dart:io';

import 'package:logging/logging.dart';
import 'package:server_utils/database.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  test('Start database in empty directory', () async {
    var dataPath = Postgres.temporaryPath();
    var postgres = Postgres(dataPath);
    var server = await postgres.server();
    try {
      expect(Postgres.isDataDirectory(dataPath), true);
      var client = server.client();
      await client.execute('create database my_database', transaction: false);
      var databases = await client.listDatabases();
      expect(databases, contains('my_database'));
    } finally {
      await server.stop();
      Directory(dataPath).deleteSync(recursive: true);
    }
  });

  group('External', () {
    var testUtils = DatabaseTestUtils();

    test('Use test database', () async {
      var postgres = testUtils.postgres;
      var superclient = postgres.client();
      var databaseName = 'postgres_test_1';
      var userName = 'postgres_test_1_user';
      var password = 'postgres_test_1_password';
      await superclient.createUser(userName, password: password);
      try {
        var users = await superclient.listUsers();
        var foundRole = users.firstWhere((u) => u.name == userName);
        expect(foundRole.attributes, isEmpty);
        await superclient.createDatabase('postgres_test_1', owner: userName);
        try {
          expect(
              await superclient.listDatabases(), contains('postgres_test_1'));

          var userClient = postgres.client(
              username: userName, password: password, database: databaseName);
          await userClient.execute('create table onetable (id serial)');
          var tables = await userClient.listTable();
          var table = tables.firstWhere((t) => t.name == 'onetable');
          expect(table.type, 'table');
          expect(table.owner, userName);
        } finally {
          await superclient.dropDatabase(databaseName);
        }
      } finally {
        await superclient.dropUser(userName);
      }
    });
  });
}
