import 'package:server_utils/migration.dart';
import 'package:server_utils/src/test_database.dart';
import 'package:logging/logging.dart';

import 'example_database_builder.dart';
import 'test_database_recreate.dart' show testDatabaseScripts;

void main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);
  var dbClient =
      testDatabaseSuperuser.copyWith(database: exampleDatabaseName).client();
  var migrator = Migrator(dbClient, [testDatabaseScripts]);
  await migrator.migrate();
}
