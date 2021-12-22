import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:process_runner/process_runner.dart';

import 'connection_options.dart';
import 'local_database.dart';
import 'utils.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

final Logger _logger = Logger('postgres');

String _dockerName(String dataPath) =>
    'postgres-dart-${hex.encode(md5.convert(utf8.encode(dataPath)).bytes)}';

class Postgres {
  final String dataPath;
  final String version;
  final String username, password, database;
  final int? port;

  Postgres(this.dataPath,
      {String? version,
      String? username,
      String? password,
      String? database,
      this.port})
      : version = version ?? '13.3',
        username = username ?? 'username',
        password = password ?? 'password',
        database = database ?? 'username';

  static String createDataPath(String name) {
    var root = path.join(Platform.environment['HOME']!, '.postgres-data');
    var userDir = Directory(path.join(root, name));
    if (!userDir.existsSync()) {
      userDir.createSync(recursive: true);
    }
    return userDir.path;
  }

  static String get temporaryPath {
    var userDir = Directory(createDataPath('temp'));
    return userDir.createTempSync().path;
  }

  static bool isDataDirectory(String dataPath) {
    return File(path.join(dataPath, 'pgdata', 'PG_VERSION')).existsSync();
  }

  Postgres copyWith({
    String? dataPath,
    String? version,
    String? username,
    String? password,
    String? database,
    int? port,
  }) {
    return Postgres(
      dataPath ?? this.dataPath,
      version: version ?? this.version,
      username: username ?? this.username,
      password: password ?? this.password,
      database: database ?? this.database,
      port: port ?? this.port,
    );
  }

  Future<T> runServer<T>(FutureOr<T> Function(PostgresServer) callback) async {
    var postgresServer = await server();
    try {
      return await callback(postgresServer);
    } finally {
      await postgresServer.stop();
    }
  }

  Future<PostgresServer> server() async {
    var port = this.port;
    for (var i = 0; i < 5; i++) {
      if (port == null || port == 0) {
        port = await findUnusedPort();
      }

      var server = PostgresServer._(this, port: port);
      try {
        await server._start();
        return server;
      } on _AddressAlreadyInUseException catch (_) {
        // Continue the loop
      }
    }

    throw Exception('Cannot find a free port');
  }

  void _checkHasPort() {
    if (port == null) {
      throw Exception(
          'When no port is specified, client should be created from the PostgresServer object');
    }
  }

  ConnectionOptions get connectionOptions {
    _checkHasPort();

    return ConnectionOptions(
      user: username,
      password: password,
      database: database,
      port: port,
      hostname: 'localhost',
    );
  }

  PostgresClient client(
      {String? username, String? password, String? database}) {
    _checkHasPort();

    return clientFromOptions(ConnectionOptions(
      user: username ?? this.username,
      password: password ?? this.password,
      database: database ?? this.database,
      port: port,
      hostname: 'localhost',
    ));
  }

  PostgresClient clientFromOptions(ConnectionOptions options) =>
      PostgresClient(options, dataPath: dataPath);

  Future<LocalDatabase> createDatabase(
      {String? databaseName,
      String? template,
      String? username,
      String? password}) async {
    databaseName ??= 'db_${DateTime.now().millisecondsSinceEpoch}';

    var superUserClient = client();
    if (username != null) {
      password ??= username;
      await superUserClient.createUser(username, password: password);
    } else {
      username = this.username;
      password = this.password;
    }

    await superUserClient.createDatabase(databaseName,
        owner: username, template: template);

    return LocalDatabase(
        this,
        ConnectionOptions(
            hostname: 'localhost',
            port: port!,
            user: username,
            password: password,
            database: databaseName));
  }
}

/// A utility class to start and stop a PostgreSQL server process.
class PostgresServer {
  final _processStreamSubscriptions = <StreamSubscription>[];
  final Postgres _postgres;

  PostgresServer._(this._postgres, {required this.port});

  /// Location of the database storage area
  String get dataPath => _postgres.dataPath;

  final int port;
  Process? _process;

  Future<void> _start() async {
    var process = _process;
    assert(process == null);

    var innerPort = 5432;
    _process = process = await Process.start('docker', [
      'run',
      '--rm',
      '--name',
      _dockerName(dataPath),
      '-e',
      'POSTGRES_USER=${_postgres.username}',
      '-e',
      'POSTGRES_PASSWORD=${_postgres.password}',
      '-e',
      'POSTGRES_DB=${_postgres.database}',
      '-e',
      'PGDATA=/var/lib/postgresql/data/pgdata',
      //TODO(xha): make it work and add a flag. This could speed up db creation.
      //'-e',
      //'POSTGRES_INITDB_ARGS="--no-sync"',
      '-v',
      '$dataPath:/var/lib/postgresql/data',
      '--publish',
      '$port:$innerPort',
      'postgres:${_postgres.version}',
    ]);

    try {
      await for (String errorLine in process.stderr
          .transform(const Utf8Decoder())
          .transform(const LineSplitter())) {
        _logger.info('Starting postgres: $errorLine');
        var listeningMatch =
            RegExp(r'listening .+, port ([0-9]+)$').firstMatch(errorLine);
        if (listeningMatch != null) {
          assert(listeningMatch.group(1) == '$innerPort');
        }
        if (errorLine
            .contains('database system is ready to accept connections')) {
          return;
        }
        if (RegExp(r'could not bind .* Address already in use$')
            .hasMatch(errorLine)) {
          throw _AddressAlreadyInUseException();
        }

        if (errorLine.contains('FATAL:')) {
          throw Exception(errorLine);
        }
      }
      throw Exception('Could not start the server');
    } catch (e) {
      process.kill();
      _process = null;
      rethrow;
    }
  }

  PostgresClient client(
      {String? username, String? password, String? database}) {
    return PostgresClient(
      ConnectionOptions(
          hostname: 'localhost',
          port: port,
          user: username ?? _postgres.username,
          password: password ?? _postgres.password,
          database: database ?? _postgres.database),
      dataPath: dataPath,
    );
  }

  Future stop() async {
    var process = _process!;

    process.kill(ProcessSignal.sigint);

    await process.exitCode;

    for (var subscription in _processStreamSubscriptions) {
      await subscription.cancel();
    }
    _processStreamSubscriptions.clear();

    _process = null;
  }
}

class _AddressAlreadyInUseException implements Exception {}

/// A wrapper around the `psql` utility.
class PostgresClient {
  static final Logger _logger = Logger('PostgresClient');

  final String dataPath;

  final ConnectionOptions connectionOptions;

  PostgresClient(this.connectionOptions, {required this.dataPath});

  Future<void> createUser(String userName, {required String password}) async {
    await execute("""
create user $userName;
alter user $userName with encrypted password '${password.replaceAll("'", r"\'")}';
""");
  }

  Future<void> createDatabase(String databaseName,
      {String? owner, String? template}) async {
    var params = {
      if (owner != null) 'owner': owner,
      if (template != null) 'template': template,
    };

    var buffer = StringBuffer()..write('create database $databaseName');
    if (params.isNotEmpty) {
      buffer.write(' with ');
      for (var param in params.entries) {
        buffer.write('${param.key} ${param.value}');
      }
    }

    await execute('$buffer');
  }

  Future<void> dropDatabase(String databaseName,
      {bool? ifExists, bool? force}) async {
    ifExists ??= false;
    force ??= false;

    var command = 'drop database $databaseName';
    if (ifExists) {
      command += ' if exists';
    }
    if (force) {
      command += ' with (force)';
    }

    await execute(command);
  }

  Future<void> dropUser(String userName, {bool? ifExists}) async {
    ifExists ??= false;

    var command = 'drop user $userName';
    if (ifExists) {
      command += ' if exists';
    }

    await execute(command);
  }

  Future<void> grandAllPrivileges(String userName, {String? database}) {
    database ??= connectionOptions.database;
    database!;
    return execute('''
GRANT CONNECT ON DATABASE $database TO $userName;
GRANT USAGE ON SCHEMA public TO $userName;
GRANT ALL PRIVILEGES ON DATABASE $database TO $userName;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $userName;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $userName;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $userName;
ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO $userName;
''', database: database);
  }

  Future<bool> userExists(String userName) async {
    var results = await _runPsql([
      '--tuples-only',
      '--no-align',
      '--command',
      "SELECT 1 FROM pg_roles WHERE rolname='${userName.replaceAll("'", r"\'")}'",
    ]);

    return results.trim() == '1';
  }

  Future<bool> databaseExists(String database) async {
    var databases = await listDatabases();
    return databases.contains(database);
  }

  Future<void> execute(String script,
      {String? database, bool? transaction}) async {
    /*
      psql is the PostgreSQL interactive terminal.

      Usage:
        psql [OPTION]... [DBNAME [USERNAME]]

      General options:
        -c, --command=COMMAND    run only single command (SQL or internal) and exit
        -d, --dbname=DBNAME      database name to connect to (default: "xavier")
        -f, --file=FILENAME      execute commands from file, then exit
        -l, --list               list available databases, then exit
        -v, --set=, --variable=NAME=VALUE
                                 set psql variable NAME to VALUE
                                 (e.g., -v ON_ERROR_STOP=1)
        -V, --version            output version information, then exit
        -X, --no-psqlrc          do not read startup file (~/.psqlrc)
        -1 ("one"), --single-transaction
                                 execute as a single transaction (if non-interactive)
        -?, --help[=options]     show this help, then exit
            --help=commands      list backslash commands, then exit
            --help=variables     list special variables, then exit

      Input and output options:
        -a, --echo-all           echo all input from script
        -b, --echo-errors        echo failed commands
        -e, --echo-queries       echo commands sent to server
        -E, --echo-hidden        display queries that internal commands generate
        -L, --log-file=FILENAME  send session log to file
        -n, --no-readline        disable enhanced command line editing (readline)
        -o, --output=FILENAME    send query results to file (or |pipe)
        -q, --quiet              run quietly (no messages, only query output)
        -s, --single-step        single-step mode (confirm each query)
        -S, --single-line        single-line mode (end of line terminates SQL command)

      Output format options:
        -A, --no-align           unaligned table output mode
        -F, --field-separator=STRING
                                 field separator for unaligned output (default: "|")
        -H, --html               HTML table output mode
        -P, --pset=VAR[=ARG]     set printing option VAR to ARG (see \pset command)
        -R, --record-separator=STRING
                                 record separator for unaligned output (default: newline)
        -t, --tuples-only        print rows only
        -T, --table-attr=TEXT    set HTML table tag attributes (e.g., width, border)
        -x, --expanded           turn on expanded table output
        -z, --field-separator-zero
                                 set field separator for unaligned output to zero byte
        -0, --record-separator-zero
                                 set record separator for unaligned output to zero byte

      Connection options:
        -h, --host=HOSTNAME      database server host or socket directory (default: "local socket")
        -p, --port=PORT          database server port (default: "5432")
        -U, --username=USERNAME  database user name (default: "xavier")
        -w, --no-password        never prompt for password
        -W, --password           force password prompt (should happen automatically)
     */

    _logger.finest('Execute $script');
    await _psql((stdin) async {
      stdin.writeln('$script;');
      await stdin.close();
    }, database: database, transaction: transaction);
  }

  Future<void> executeFile(File file, {String? database}) async {
    await _psql((stdin) {
      return file.openRead().pipe(stdin);
    }, database: database);
  }

  List<String> get _psqlDockerArgs {
    var database = connectionOptions.database;
    var user = connectionOptions.user;
    return [
      'exec',
      '-i',
      _dockerName(dataPath),
      'psql',
      if (database != null) ...['--dbname', database],
      if (user != null) ...['--username', user],
      '--no-password',
    ];
  }

  Future<String> _psql(Function(IOSink) callback,
      {String? database, bool? transaction}) async {
    /*
    psql is the PostgreSQL interactive terminal.

    Usage:
      psql [OPTION]... [DBNAME [USERNAME]]

    General options:
      -c, --command=COMMAND    run only single command (SQL or internal) and exit
      -d, --dbname=DBNAME      database name to connect to (default: "xavier")
      -f, --file=FILENAME      execute commands from file, then exit
      -l, --list               list available databases, then exit
      -v, --set=, --variable=NAME=VALUE
                               set psql variable NAME to VALUE
                               (e.g., -v ON_ERROR_STOP=1)
      -V, --version            output version information, then exit
      -X, --no-psqlrc          do not read startup file (~/.psqlrc)
      -1 ("one"), --single-transaction
                               execute as a single transaction (if non-interactive)
      -?, --help[=options]     show this help, then exit
          --help=commands      list backslash commands, then exit
          --help=variables     list special variables, then exit

    Input and output options:
      -a, --echo-all           echo all input from script
      -b, --echo-errors        echo failed commands
      -e, --echo-queries       echo commands sent to server
      -E, --echo-hidden        display queries that internal commands generate
      -L, --log-file=FILENAME  send session log to file
      -n, --no-readline        disable enhanced command line editing (readline)
      -o, --output=FILENAME    send query results to file (or |pipe)
      -q, --quiet              run quietly (no messages, only query output)
      -s, --single-step        single-step mode (confirm each query)
      -S, --single-line        single-line mode (end of line terminates SQL command)

    Output format options:
      -A, --no-align           unaligned table output mode
      -F, --field-separator=STRING
                               field separator for unaligned output (default: "|")
      -H, --html               HTML table output mode
      -P, --pset=VAR[=ARG]     set printing option VAR to ARG (see \pset command)
      -R, --record-separator=STRING
                               record separator for unaligned output (default: newline)
      -t, --tuples-only        print rows only
      -T, --table-attr=TEXT    set HTML table tag attributes (e.g., width, border)
      -x, --expanded           turn on expanded table output
      -z, --field-separator-zero
                               set field separator for unaligned output to zero byte
      -0, --record-separator-zero
                               set record separator for unaligned output to zero byte

    Connection options:
      -h, --host=HOSTNAME      database server host or socket directory (default: "local socket")
      -p, --port=PORT          database server port (default: "5432")
      -U, --username=USERNAME  database user name (default: "xavier")
      -w, --no-password        never prompt for password
      -W, --password           force password prompt (should happen automatically)
     */
    transaction ??= false;
    var args = <String>[
      if (transaction) '--single-transaction',
      '-v',
      'ON_ERROR_STOP=1',
    ];

    var allArgs = [..._psqlDockerArgs, ...args];
    var process = await Process.start('docker', allArgs);
    _logger.fine(allArgs.map((s) => s).join(' '));

    var stdoutLines = <String>[];
    var stdoutSub = process.stdout
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .listen((line) {
      stdoutLines.add(line);
      _logger.finest(line);
    });

    var stderrLines = <String>[];
    var stderrSub = process.stderr
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .listen((line) {
      stderrLines.add(line);
      _logger.severe(line);
    });

    await callback(process.stdin);

    var exitCode = await process.exitCode;
    await stdoutSub.cancel();
    await stderrSub.cancel();
    if (exitCode != 0) {
      throw Exception(
          'psql exited with code $exitCode.\n${stderrLines.join('\n')}');
    }

    return stdoutLines.join('\n');
  }

  Future<String> _runPsql(List<String> args) async {
    var result = await ProcessRunner()
        .runProcess(['docker', ..._psqlDockerArgs, ...args]);

    if (result.exitCode != 0) {
      throw Exception(
          'psql exited with code ${result.exitCode}.\n${result.stderr}');
    }

    return result.stdout;
  }

  Future<List<String>> listDatabases() async {
    var result = await _runPsql(['--list', '--quiet', '--tuples-only']);
    return LineSplitter.split(result)
        .map((line) => line.split('|').first.trim())
        .where((n) => n.isNotEmpty)
        .toList();
  }

  Future<List<PostgresRole>> listUsers() async {
    var result =
        await _runPsql(['--quiet', '--tuples-only', '--command', r'\du']);
    return LineSplitter.split(result)
        .map((line) => line.split('|'))
        .where((n) => n.length >= 2)
        .map((l) => PostgresRole(
            l.first.trim(),
            l[1]
                .split(',')
                .map((r) => r.trim())
                .where((s) => s.isNotEmpty)
                .toSet()))
        .toList();
  }

  Future<List<PostgresTable>> listTable() async {
    var result =
        await _runPsql(['--quiet', '--tuples-only', '--command', r'\dt']);
    return LineSplitter.split(result)
        .map((line) => line.split('|'))
        .where((n) => n.length >= 4)
        .map((l) =>
            PostgresTable(l[0].trim(), l[1].trim(), l[2].trim(), l[3].trim()))
        .toList();
  }

//TODO(xha): implement
//  Future<String> dump({bool data = true, bool schema = true}) {}
//
//  Future<void> dumpTo(String path, {bool data = true, bool schema = true}) {}

// TODO(xha): Dump to Stream to http/s3/cloud
}

class PostgresRole {
  final String name;
  final Set<String> attributes;

  PostgresRole(this.name, this.attributes);
}

class PostgresTable {
  final String schema;
  final String name;
  final String type;
  final String owner;

  PostgresTable(this.schema, this.name, this.type, this.owner);
}
