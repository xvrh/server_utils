import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:postgres/postgres.dart';
import 'package:server_utils/database.dart';
import 'package:logging/logging.dart';
import 'package:server_utils/src/database/schema/schema_extractor.dart';
import 'package:watcher/watcher.dart';
import 'package:path/path.dart' as p;

import 'orm/queries_generator.dart';
import 'utils.dart';

final _logger = Logger('database_builder');

// TODO(xha): run an app. Create a temporary database, create it from scratch
// based on the migrationScripts.
// Watch all folders in migration script. For each change, recreate the db.
// Generate all Dart code based on this database (for the tables)
// Generate all the queries + watch for the queryGlobs & regenerate the query
// for 1 file when it changes.
// + Add a stdin input to force a refresh of ALL queries.

// Workflow: create a file database_builder.dart with this script
// Create an other file database_recreate.dart => a one shot file to create
//   only a database from the migration file. This is generally the test database
//   where you will have your test data?
//   => Maybe this second script is useless and a bad idea. Just always use the
// first one so it is immediatly up-to-date when you ctrl-s the file.

Future<void> runDatabaseBuilder(Postgres database, String databaseName,
    {required Set<String> migrations, required Set<String> queries}) async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  // if (!stdin.hasTerminal) {
  //   print('Run this script using the standard shell instead of IntelliJ. '
  //       'ie: dart tool/database_builder.dart');
  // }
  // stdin.lineMode = false;
  print('''
Available options:
  r: refresh all query files
  a: refresh all (migrations + query files)
''');

  var builder = _DatabaseBuilder(database, databaseName,
      migrations: migrations, queries: queries);
  await builder.run();

  builder.dispose();
}

class _DatabaseBuilder {
  final Postgres database;
  final String databaseName;
  final Set<String> migrations;
  final Set<String> queries;
  final PostgresClient _client;
  final _eventsController = StreamController();

  _DatabaseBuilder(this.database, this.databaseName,
      {required this.migrations, required this.queries})
      : _client = database.copyWith(database: databaseName).client();

  Future<void> run() async {
    await _recreateDatabase();
    await _generateAllQueries();
    _listenEvents();

    await for (var event in _eventsController.stream) {
      if (event is _RefreshQueryScriptEvent) {
        await _generateQuery(event.file);
      } else if (event is _RefreshAllQueryScriptsEvent) {
        await _generateAllQueries();
      } else if (event is _RecreateDatabaseEvent) {
        await _recreateDatabase();
        await _generateAllQueries();
      }
    }
  }

  void _listenEvents() {
    var current = Directory.current.path;
    var rootWatcher = DirectoryWatcher(current);
    rootWatcher.events.listen((event) {
      var path = p.join(current, event.path);
      for (var query in queries) {
        var glob = Glob(query);
        if (const [ChangeType.ADD, ChangeType.MODIFY].contains(event.type) &&
            glob.matches(path)) {
          _logger.info('File modified: $path');
          _eventsController.add(_RefreshQueryScriptEvent(File(path)));
        }
      }
    });

    stdin.listen((event) {
      var option = String.fromCharCodes(event);
      if (option.startsWith('r')) {
        _logger.info('Refresh all query scripts');
        _eventsController.add(_RefreshAllQueryScriptsEvent());
      }
    });
  }

  Future<void> _recreateDatabase() async {
    var superClient = database.client();
    if (await superClient.databaseExists(databaseName)) {
      await superClient.dropDatabase(databaseName, force: true);
    }
    await superClient.createDatabase(databaseName);

    var migrator = Migrator(_client, [...migrations]);
    await migrator.migrate();
  }

  Future<void> _generateAllQueries() async {
    await useConnectionOptions(_client.connectionOptions, (connection) async {
      var generator = await _queryGenerator(connection);
      for (var queryGlob in queries) {
        for (var file in Glob(queryGlob).listSync().whereType<File>()) {
          await _generateQueryFile(generator, file);
        }
      }
    });
  }

  Future<void> _generateQuery(File file) async {
    await useConnectionOptions(_client.connectionOptions, (connection) async {
      var generator = await _queryGenerator(connection);
      await _generateQueryFile(generator, file);
    });
  }

  Future<QueriesGenerator> _queryGenerator(
      PostgreSQLConnection connection) async {
    var dbSchema = await SchemaExtractor(DatabaseIO(connection)).schema();
    var evaluator = PostgresQueryEvaluator(connection);
    return QueriesGenerator(dbSchema, evaluator);
  }

  Future<void> _generateQueryFile(QueriesGenerator generator, File file) async {
    try {
      var result = await generator.generate(file.readAsStringSync(),
          filePath: file.path);
      File(p.setExtension(file.path, '.dart')).writeAsStringSync(result);
      _logger.fine('Generated query ${file.path}');
    } catch (e, s) {
      _logger.warning('Failed to generate SQL queries file '
          '(file://${p.normalize(p.absolute(file.path))})\n$e\n$s');
    }
  }

  void dispose() {
    _eventsController.close();
  }
}

abstract class _Event {}

class _RecreateDatabaseEvent implements _Event {}

class _RefreshQueryScriptEvent implements _Event {
  final File file;

  _RefreshQueryScriptEvent(this.file);
}

class _RefreshAllQueryScriptsEvent implements _Event {}
