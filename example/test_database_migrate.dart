import 'package:server_utils/migration.dart';
import 'package:server_utils/src/test_database.dart';
import 'package:logging/logging.dart';

import 'test_database_recreate.dart' show testDatabaseName, testDatabaseScripts;

void main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);
  var dbClient = thisPackageTestDatabase.client(database: testDatabaseName);
  var migrator = Migrator(dbClient, [testDatabaseScripts]);
  await migrator.migrate();
}
