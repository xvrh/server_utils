import 'dart:io';
import 'package:package_config/package_config.dart';
import '../postgres.dart';
import '../utils.dart';
import 'isolate_runner.dart';
import 'migration_context.dart';
import 'script.dart';

class Migrator {
  static const _migrationTable = '_migration_history';
  final PostgresClient client;
  final List<String> scriptLocations;

  Migrator(this.client, this.scriptLocations);

  Future<void> migrate() async {
    var connection = connectionFromEndpoint(client.endpoint);
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
      var migrationTableExists = existResult[0][0] as bool;
      if (!migrationTableExists) {
        var packageConfig = (await findPackageConfig(Directory.current))!;
        var testUtilsPackage = packageConfig['server_utils']!;
        var sqlPath = testUtilsPackage.packageUriRoot
            .resolve('src/database/migration/migration_history.sql')
            .toFilePath();
        await connection.execute(await File(sqlPath).readAsString());
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
            if (script.type == ScriptType.sql) {
              await client.executeFile(script.file);
            } else {
              await isolateRunner!.callMigrateMethod(script.file.absolute.path);
            }
          } on Exception catch (e) {
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

//TODO(xha): replace with auto generated version and move all queries
// to generated script
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
