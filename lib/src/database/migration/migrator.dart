import 'dart:io';
import 'package:package_config/package_config.dart';
import 'package:server_utils/database.dart';
import 'default_migration_client.dart';
import 'isolate_runner.dart';
import 'migration_client.dart';
import 'script.dart';
import 'history_crud.dart';
import 'history.queries.dart';

class Migrator {
  static const _migrationTable = '_migration_history';
  final MigrationClient client;
  final List<String> scriptLocations;

  Migrator(this.client, this.scriptLocations);

  factory Migrator.fromClient(
      PostgresClient client, List<String> scriptLocations) {
    return Migrator(PostgresMigrationClient(client), scriptLocations);
  }

  Future<void> migrate() async {
    await client.runConnection((c) async {
      var database = DatabaseIO(c);
      var migrationTableExists =
          await database.tableExists(_migrationTable, schemaName: 'public');
      if (!migrationTableExists) {
        var packageConfig = (await findPackageConfig(Directory.current))!;
        var testUtilsPackage = packageConfig['server_utils']!;
        var sqlPath = testUtilsPackage.packageUriRoot
            .resolve('src/database/migration/ddl.sql')
            .toFilePath();
        await database.execute(await File(sqlPath).readAsString());
      }

      var migrations = await database.listMigrations();

      var scripts = await scriptsFromPaths(scriptLocations);
      var nonExecutedMigrations = scripts.where((script) => migrations
          .every((m) => m.name.toLowerCase() != script.name.toLowerCase()));

      var nonExecutedDartMigrations = nonExecutedMigrations
          .where((s) => s.type == ScriptType.dart)
          .toList();

      IsolateRunner? isolateRunner;
      if (nonExecutedDartMigrations.isNotEmpty) {
        var migrationContext = client.migrationContext();
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

          await database.migrationHistory.insert(name: script.name);
        }
      } finally {
        await isolateRunner?.stop();
      }
    });
  }

  Future<void> baseline() async {
    // Create the table "migrations" with all the names but doesn't apply the changes
    throw UnimplementedError();
  }
}

class MigrationException implements Exception {
  final String filePath;
  final Exception innerException;

  MigrationException(this.filePath, this.innerException);

  @override
  String toString() =>
      'Error while execution migration $filePath.\n$innerException';
}
