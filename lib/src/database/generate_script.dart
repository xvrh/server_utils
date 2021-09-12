import 'dart:io';

// TODO(xha): run an app. Create a temporary database, create it from scratch
// based on the migrationScripts.
// Watch all folders in migration script. For each change, recreate the db.
// Generate all Dart code based on this database (for the tables)
// Generate all the queries + watch for the queryGlobs & regenerate the query
// for 1 file when it changes.
// + Add a stdin input to force a refresh of ALL queries.

// Workflow: create a file database_watcher.dart with this script
// Create an other file database_recreate.dart => a one shot file to create
//   only a database from the migration file. This is generally the test database
//   where you will have your test data?
//   => Maybe this second script is useless and a bad idea. Just always use the
// first one so it is immediatly up-to-date when you ctrl-s the file.

Future<void> runDatabaseWatcher(
    {required Set<String> migrations, required Set<String> queries}) {
  // 1. Force create the database
  // 2. Generate the queries
  // 3. Watch for events + watch for stdin inputs
}

/// Generate all .dart files for
Future<void> generateDartFilesForDatabase(
    {required Set<String> sqlScripts, required Set<String> queryGlobs}) async {
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
      generateFile(connection, file);
    }
  });
}

// This is a quick version of the script above. But it doesn't recreate the database
// it use an existing version of the database and re-run the script
//TODO(xha): maybe prefer a version where we run the migration normally?
// We need more on-the-field experiment to understand the workflow.
Future<void> generateQueriesFiles(
    {required String databaseName, required Set<String> queryGlobs}) {}

void main() async {}
