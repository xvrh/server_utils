import 'isolate_runner.dart';
import 'migration_context.dart';
import 'script.dart';
import 'package:database/src/utils.dart';

import '../postgres.dart';

class Migrator {
  static const _migrationTable = '_migration_history';
  final PostgresClient client;
  final List<String> scriptLocations;

  Migrator(this.client, this.scriptLocations);

  Future<void> migrate() async {
    var connection = connectionFromOptions(client.connectionOptions);
    await connection.open();
    try {
      var existResult = await connection.query('''
select exists (
   select 1
   from   information_schema.tables 
   where  table_schema = 'public'
   and    table_name = '$_migrationTable'
);
''');
      bool migrationTableExists = existResult[0][0];
      if (!migrationTableExists) {
        await connection.execute(await Resource(
                'package:database/src/migration/migration_history.sql')
            .readAsString());
      }

      var migrations =
          (await connection.query('select * from $_migrationTable'))
              .map((r) => MigrationHistory.fromRow(r.toColumnMap()))
              .toList();

      var scripts = await scriptsFromPaths(scriptLocations);
      var nonExecutedMigrations = scripts.where((script) => migrations
          .every((m) => m.name.toLowerCase() != script.name.toLowerCase()));

      var nonExecutedDartMigrations = nonExecutedMigrations
          .where((s) => s.type == ScriptType.dart)
          .toList();

      IsolateRunner? isolateRunner;
      if (nonExecutedDartMigrations.isNotEmpty) {
        var migrationContext = MigrationContext.closed(client);
        isolateRunner = await IsolateRunner.start(
            nonExecutedDartMigrations.map((s) => s.file.absolute.path).toList(),
            method: 'migrate',
            migrationContext: migrationContext);
      }
      try {
        for (var script in nonExecutedMigrations) {
          try {
            //TODO(xha): est-ce qu'il faut être plus strict sur l'ordre autorisé des migrations?
            // Est-ce qu'il faut être plus stric si 2 migrations ont le même nom?

            if (script.type == ScriptType.sql) {
              await client.executeFile(script.file);
            } else {
              await isolateRunner.callMigrateMethod(script.file.absolute.path);
            }
          } catch (e) {
            throw MigrationException(script.file.path, e);
          }

          await connection.execute(
              'insert into $_migrationTable (name) values (@name)',
              substitutionValues: {'name': script.name});
        }
      } finally {
        await isolateRunner?.stop();
      }
    } finally {
      await connection.close();
    }
  }

  Future<void> baseline() async {
    // Create the table "migrations" with all the names but doesn't apply the changes
    throw UnimplementedError();
  }
}

class MigrationHistory {
  final int id;
  final String name;
  final DateTime date;

  MigrationHistory({required this.id, required this.name, required this.date});

  factory MigrationHistory.fromRow(Map<String, dynamic> row) =>
      MigrationHistory(
          id: row['id'] as int,
          name: row['name'] as String,
          date: row['date'] as DateTime);
}

class MigrationException implements Exception {
  final String filePath;
  final Exception innerException;

  MigrationException(this.filePath, this.innerException);

  @override
  String toString() =>
      'Error while execution migration $filePath.\n$innerException';
}
