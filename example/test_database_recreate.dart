import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:server_utils/migration.dart';
import 'package:server_utils/src/database/utils.dart';
import 'package:server_utils/src/test_database.dart';
import 'package:logging/logging.dart';

final testDatabaseScripts = 'example/test_database';

void main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);
  var databaseName = testDatabaseName;
  var superClient = testDatabaseSuperuser.client();
  if (await superClient.databaseExists(databaseName)) {
    await superClient.dropDatabase(databaseName, force: true);
  }
  await superClient.createDatabase(databaseName);
  var dbClient = testDatabase.client();

  var migrator = Migrator(dbClient, [testDatabaseScripts]);
  await migrator.migrate();

  //await useConnectionOptions(testDatabase.connectionOptions,
  //    (connection) async {
  //  for (var file
  //      in Glob('example/**.queries.sql').listSync().whereType<File>()) {
  //    await generateSqlQueryFile(connection, file);
  //  }
  //});
}
