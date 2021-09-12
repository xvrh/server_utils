import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:server_utils/database.dart';
import 'package:server_utils/migration.dart';
import 'package:server_utils/src/database/orm/sql_file_generator.dart';
import 'package:server_utils/src/database/orm/sql_file_parser.dart';
import 'package:server_utils/src/database/utils.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:server_utils/src/test_database.dart';

void main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);
  var databaseName = 'server_utils_database';
  var database = testDatabase;
  var superClient = database.client();
  if (await superClient.databaseExists(databaseName)) {
    await superClient.dropDatabase(databaseName, force: true);
  }
  await superClient.createDatabase(databaseName);
  var dbClient = database.copyWith(database: databaseName).client();

  var migrator = Migrator(dbClient, ['db_for_generate_queries/**']);
  await migrator.migrate();

  await useConnectionOptions(dbClient.connectionOptions, (connection) async {
    for (var file in Glob('lib/**.queries.sql').listSync().whereType<File>()) {
      var generator = SqlFileGenerator(connection);
      var code = await generator.generate(parseSqlFile(file.readAsStringSync()),
          fileName: p.basenameWithoutExtension(file.path));
      File(p.join(p.dirname(file.path),
              '${p.basenameWithoutExtension(file.path)}.dart'))
          .writeAsStringSync(code);
    }
  });
}
