import 'dart:io';

import 'package:server_utils/postgres.dart';
import 'package:test/test.dart';

void main() {
  test('Start database in empty directory', () async {
    var dataPath = Postgres.temporaryPath;
    var postgres = Postgres(dataPath);
    var server = await postgres.server();
    expect(Postgres.isDataDirectory(dataPath), true);
    var client = server.client();
    await client.execute('create database my_database', transaction: false);
    var databases = await client.listDatabases();
    expect(databases, contains('my_database'));
    await server.stop();
    Directory(dataPath).deleteSync(recursive: true);
  });
}
