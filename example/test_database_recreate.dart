import 'package:server_utils/migration.dart';
import 'package:server_utils/src/test_database.dart';
import 'package:logging/logging.dart';

final testDatabaseName = 'test';
final testDatabaseScripts = 'example/test_database';

void main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);
  var superClient = thisPackageTestDatabase.client();
  if (await superClient.databaseExists(testDatabaseName)) {
    await superClient.dropDatabase(testDatabaseName, force: true);
  }
  await superClient.createDatabase(testDatabaseName);
  var dbClient = thisPackageTestDatabase.client(database: testDatabaseName);

  var migrator = Migrator(dbClient, [testDatabaseScripts]);
  await migrator.migrate();
}
