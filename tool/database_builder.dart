import 'dart:io';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'package:server_utils/database_builder.dart';

final databaseServer =
    Postgres(Postgres.createDataPath('local_database'), port: 8888);

const databaseName = 'tool_database';

void main() async {
  Logger.root
    ..onRecord.listen(print)
    ..level = Level.ALL;

  await runDatabaseBuilder(
    databaseServer,
    databaseName,
    migrations: [],
    queries: ['lib/**.queries.dart'],
    afterCreate: _afterCreate,
    afterRefresh: _afterRefresh,
  );
}

Future<void> _afterCreate(PostgreSQLConnection connection) async {}

Future<void> _afterRefresh(PostgreSQLConnection connection) async {
  var database = DatabaseIO(connection);
  var schema = await SchemaExtractor(database).schema(tableFilter: (_) => true);
  var code = DartGenerator(
    schema.withConfig({}),
  );
  var schemaFile = 'history_schema.dart';
  File('lib/src/database/migration/$schemaFile')
      .writeAsStringSync(await code.generateEntities());

  File('lib/src/database/migration/history_crud.dart')
      .writeAsStringSync(await code.generateCrudFile(imports: [schemaFile]));
}
