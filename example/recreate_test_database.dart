import 'package:server_utils/migration.dart';
import 'package:server_utils/src/test_database.dart';
import 'package:logging/logging.dart';

void main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);
  var databaseName = 'test';
  var superClient = thisPackageTestDatabase.client();
  if (await superClient.databaseExists(databaseName)) {
    await superClient.dropDatabase(databaseName);
  }
  await superClient.createDatabase(databaseName);
  var dbClient = thisPackageTestDatabase.client(database: databaseName);

  var migrator = Migrator(dbClient, ['example/test_database']);
  await migrator.migrate();
}
