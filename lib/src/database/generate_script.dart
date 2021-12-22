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

const _refreshAllQueriesCommand = 'r';
const _refreshAllCommand = 'a';

Future<void> runDatabaseBuilder(
  Postgres database,
  String databaseName, {
  required Set<String> migrations,
  required Set<String> queries,
  required Future<void> Function(PostgreSQLConnection) afterCreate,
}) async {
  // if (!stdin.hasTerminal) {
  //   print('Run this script using the standard shell instead of IntelliJ. '
  //       'ie: dart tool/database_builder.dart');
  // }
  // stdin.lineMode = false;
  print('''
Available options:
  $_refreshAllQueriesCommand: refresh all query files
  $_refreshAllCommand: recreate database
''');

  var builder = _DatabaseBuilder(
    database,
    databaseName,
    migrations: migrations,
    queries: queries,
    afterCreate: afterCreate,
  );
  await builder.run();

  builder.dispose();
}

class _DatabaseBuilder {
  final Postgres database;
  final String databaseName;
  final Set<String> migrations;
  final Set<String> queries;
  final Future<void> Function(PostgreSQLConnection) afterCreate;
  final PostgresClient _client;
  final _eventsController = StreamController();

  _DatabaseBuilder(
    this.database,
    this.databaseName, {
    required this.migrations,
    required this.queries,
    required this.afterCreate,
  }) : _client = database.copyWith(database: databaseName).client();

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
      if (option.startsWith(_refreshAllQueriesCommand)) {
        _logger.info('Refresh all query scripts');
        _eventsController.add(_RefreshAllQueryScriptsEvent());
      } else if (option.startsWith(_refreshAllCommand)) {
        _logger.info('Refresh all');
        _eventsController.add(_RecreateDatabaseEvent());
      }
    });
  }

  Future<void> _recreateDatabase() async {
    var globalStopwatch = Stopwatch()..start();
    var stopwatch = Stopwatch()..start();
    var superClient = database.client();
    if (await superClient.databaseExists(databaseName)) {
      await superClient.dropDatabase(databaseName, force: true);
    }
    _logger.fine('Drop database in ${stopwatch.elapsed}');
    stopwatch.reset();
    await superClient.createDatabase(databaseName);
    _logger.fine('Create database in ${stopwatch.elapsed}');

    stopwatch.reset();

    try {
      var migrator = Migrator(_client, [...migrations]);
      await migrator.migrate();
      _logger.fine('Apply migrations in ${stopwatch.elapsed}');

      stopwatch.reset();
      await useConnectionOptions(_client.connectionOptions, afterCreate);
      _logger.fine('After create actions in ${stopwatch.elapsed}');

      _logger.info('Recreated database step in ${globalStopwatch.elapsed}');
    } catch (e, s) {
      _logger.warning('Failed to re-create database: $e\n$s');
    }
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
