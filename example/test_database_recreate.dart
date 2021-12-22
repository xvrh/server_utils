import 'package:server_utils/migration.dart';
import 'package:server_utils/src/test_database.dart';
import 'package:logging/logging.dart';

import 'example_database_builder.dart';

final testDatabaseScripts = 'example/test_database';

void main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);
  var databaseName = exampleDatabaseName;
  var superClient = testDatabaseSuperuser.client();
  if (await superClient.databaseExists(databaseName)) {
    await superClient.dropDatabase(databaseName, force: true);
  }
  await superClient.createDatabase(databaseName);
  var dbClient =
      testDatabaseSuperuser.copyWith(database: databaseName).client();

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
