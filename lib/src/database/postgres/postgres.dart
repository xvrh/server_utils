import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'utils.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

final Logger _logger = Logger('postgres');

class PostgresBinaries {
  final String _root;

  PostgresBinaries(this._root);

  const PostgresBinaries.fromEnvironmentPath() : _root = null;

  factory PostgresBinaries.fromJson(Map<String, dynamic> json) =>
      PostgresBinaries(json['root']);

  Map<String, dynamic> toJson() {
    return {'root': _root};
  }

  bool get isInEnvironmentPath => _root == null;

  String get binFolder => p.join(_root, 'pgsql', 'bin');

  String get postgres => _tool('postgres');

  String get initdb => _tool('initdb');

  String get createuser => _tool('createuser');

  String get createdb => _tool('createdb');

  String get dropdb => _tool('dropdb');

  String get dropuser => _tool('dropuser');

  String get psql => _tool('psql');

  String _exe(String name) => name + (Platform.isWindows ? '.exe' : '');

  String _tool(String name) =>
      isInEnvironmentPath ? _exe(name) : p.join(binFolder, _exe(name));
}

class Postgres {
  final PostgresBinaries binaries;

  Postgres({PostgresBinaries binaries})
      : binaries = binaries ?? PostgresBinaries.fromEnvironmentPath();

  Future<bool> isDataDirectory(String dataPath) {
    return File(p.join(dataPath, 'PG_VERSION')).exists();
  }

  Future initDataDirectory(String dataPath,
      {String superUser, bool noSync = false}) async {
    /*
      initdb initializes a PostgreSQL database cluster.

      Usage:
        initdb [OPTION]... [DATADIR]

      Options:
        -A, --auth=METHOD         default authentication method for local connections
            --auth-host=METHOD    default authentication method for local TCP/IP connections
            --auth-local=METHOD   default authentication method for local-socket connections
       [-D, --pgdata=]DATADIR     location for this database cluster
        -E, --encoding=ENCODING   set default encoding for new databases
        -g, --allow-group-access  allow group read/execute on data directory
            --locale=LOCALE       set default locale for new databases
            --lc-collate=, --lc-ctype=, --lc-messages=LOCALE
            --lc-monetary=, --lc-numeric=, --lc-time=LOCALE
                                  set default locale in the respective category for
                                  new databases (default taken from environment)
            --no-locale           equivalent to --locale=C
            --pwfile=FILE         read password for the new superuser from file
        -T, --text-search-config=CFG
                                  default text search configuration
        -U, --username=NAME       database superuser name
        -W, --pwprompt            prompt for a password for the new superuser
        -X, --waldir=WALDIR       location for the write-ahead log directory
            --wal-segsize=SIZE    size of WAL segments, in megabytes

      Less commonly used options:
        -d, --debug               generate lots of debugging output
        -k, --data-checksums      use data page checksums
        -L DIRECTORY              where to find the input files
        -n, --no-clean            do not clean up after errors
        -N, --no-sync             do not wait for changes to be written safely to disk
        -s, --show                show internal settings
        -S, --sync-only           only sync data directory

      Other options:
        -V, --version             output version information, then exit
        -?, --help                show this help, then exit

      If the data directory is not specified, the environment variable PGDATA
      is used.
     */

    var args = <String>[
      ...['-E', 'UTF8'],
      '--locale=en_US',
      if (superUser != null) ...['-U', superUser],
      if (noSync) '--no-sync',
      dataPath,
    ];

    _logger.info('initdb ${args.join(' ')}');

    ProcessResult result = await Process.run(binaries.initdb, args);
    _logger.fine('initdb stderr: ${result.stderr}');
    _logger.fine('initdb stdout: ${result.stdout}');

    if (result.exitCode != 0) {
      throw Exception(
          'initdb failed with exit code ${result.exitCode}\n${result.stderr}');
    }
  }

  Future<T> runServer<T>(T Function(PostgresServer) callback,
      {String dataPath, int port, String hostname}) async {
    PostgresServer postgresServer =
        await server(dataPath: dataPath, port: port, hostname: hostname);
    try {
      return await callback(postgresServer);
    } finally {
      await postgresServer.stop();
    }
  }

  Future<PostgresServer> server(
      {String dataPath, int port, String hostname}) async {
    for (int i = 0; i < 5; i++) {
      if (port == null || port == 0) {
        port = await findUnusedPort();
      }

      var server = PostgresServer._(
          binaries: binaries,
          dataPath: dataPath,
          port: port,
          hostname: hostname);
      try {
        await server._start();
        return server;
      } on _AddressAlreadyInUseException catch (_) {
        // Continue the loop
      }
    }

    throw Exception('Cannot find a free port');
  }

  PostgresClient client(
      {String hostname,
      int port,
      @required String user,
      @required String password,
      String database}) {
    return clientFromOptions(ConnectionOptions(
        hostname: hostname,
        port: port,
        user: user,
        password: password,
        database: database));
  }

  PostgresClient clientFromOptions(ConnectionOptions options) =>
      PostgresClient(options, binaries: binaries);
}

/// A utility class to start and stop a PostgreSQL server process.
class PostgresServer {
  final _processStreamSubscriptions = <StreamSubscription>[];

  PostgresServer._(
      {PostgresBinaries binaries, this.dataPath, this.port, this.hostname})
      : binaries = binaries ?? const PostgresBinaries.fromEnvironmentPath() {
    assert(port != null);
  }

  final PostgresBinaries binaries;

  /// Location of the database storage area
  final String dataPath;

  // Host name or IP address to listen on
  final String hostname;

  final int port;
  Process _process;

  Future<void> _start() async {
    assert(_process == null);
    assert(port != null);

    var args = <String>['-p', '$port'];

    if (dataPath != null) {
      args.addAll(['-D', dataPath]);
    }

    if (hostname != null) {
      args.addAll(['-h', hostname]);
    }

    _process = await Process.start(binaries.postgres, args);
    try {
      await for (String errorLine in _process.stderr
          .transform(const Utf8Decoder())
          .transform(const LineSplitter())) {
        var listeningMatch =
            RegExp(r'listening .+, port ([0-9]+)$').firstMatch(errorLine);
        if (listeningMatch != null) {
          assert(listeningMatch.group(1) == '$port');
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
      _process.kill();
      _process = null;
      rethrow;
    }
  }

  PostgresClient client(
      {@required String user, @required String password, String database}) {
    return PostgresClient(
        ConnectionOptions(
            hostname: hostname,
            port: port,
            user: user,
            password: password,
            database: database),
        binaries: binaries);
  }

  Future stop() async {
    assert(_process != null);

    _process.kill();

    await _process.exitCode;

    _processStreamSubscriptions.forEach((s) => s.cancel());
    _processStreamSubscriptions.clear();

    _process = null;
  }
}

class _AddressAlreadyInUseException implements Exception {}

/// A wrapper around the `psql` utility.
class PostgresClient {
  static final Logger _logger = Logger('PostgresClient');

  final PostgresBinaries binaries;

  final ConnectionOptions connectionOptions;

  PostgresClient(this.connectionOptions, {@required PostgresBinaries binaries})
      : binaries = binaries ?? const PostgresBinaries.fromEnvironmentPath();

  Future<void> createUser(String userName, {@required String password}) async {
    /*
      createuser creates a new PostgreSQL role.

      Usage:
        createuser [OPTION]... [ROLENAME]

      Options:
        -c, --connection-limit=N  connection limit for role (default: no limit)
        -d, --createdb            role can create new databases
        -D, --no-createdb         role cannot create databases (default)
        -e, --echo                show the commands being sent to the server
        -g, --role=ROLE           new role will be a member of this role
        -i, --inherit             role inherits privileges of roles it is a
                                  member of (default)
        -I, --no-inherit          role does not inherit privileges
        -l, --login               role can login (default)
        -L, --no-login            role cannot login
        -P, --pwprompt            assign a password to new role
        -r, --createrole          role can create new roles
        -R, --no-createrole       role cannot create roles (default)
        -s, --superuser           role will be superuser
        -S, --no-superuser        role will not be superuser (default)
        -V, --version             output version information, then exit
        --interactive             prompt for missing role name and attributes rather
                                  than using defaults
        --replication             role can initiate replication
        --no-replication          role cannot initiate replication
        -?, --help                show this help, then exit

      Connection options:
        -h, --host=HOSTNAME       database server host or socket directory
        -p, --port=PORT           database server port
        -U, --username=USERNAME   user name to connect as (not the one to create)
        -w, --no-password         never prompt for password
        -W, --password            force password prompt
     */

    var args = <String>[];

    args.add(userName);

    ProcessResult result = await Process.run(binaries.createuser, args,
        environment: connectionOptions._toEnvironment());

    if (result.stderr is String && result.stderr.isNotEmpty) {
      _logger.fine('createuser stderr: ${result.stderr}');
    }
    if (result.stdout is String && result.stdout.isNotEmpty) {
      _logger.fine('createuser stdout: ${result.stdout}');
    }

    if (result.exitCode != 0) {
      throw Exception(
          'createuser failed with exit code ${result.exitCode}\n${result.stderr}');
    }

    await execute(
        "alter user $userName with encrypted password '${password.replaceAll("'", "\'")}'");
  }

  Future<void> createDatabase(String databaseName,
      {String owner, String template}) async {
    /*
      createdb creates a PostgreSQL database.

      Usage:
        createdb [OPTION]... [DBNAME] [DESCRIPTION]

      Options:
        -D, --tablespace=TABLESPACE  default tablespace for the database
        -e, --echo                   show the commands being sent to the server
        -E, --encoding=ENCODING      encoding for the database
        -l, --locale=LOCALE          locale settings for the database
            --lc-collate=LOCALE      LC_COLLATE setting for the database
            --lc-ctype=LOCALE        LC_CTYPE setting for the database
        -O, --owner=OWNER            database user to own the new database
        -T, --template=TEMPLATE      template database to copy
        -V, --version                output version information, then exit
        -?, --help                   show this help, then exit

      Connection options:
        -h, --host=HOSTNAME          database server host or socket directory
        -p, --port=PORT              database server port
        -U, --username=USERNAME      user name to connect as
        -w, --no-password            never prompt for password
        -W, --password               force password prompt
        --maintenance-db=DBNAME      alternate maintenance database

      By default, a database with the same name as the current user is created.
     */

    var args = <String>[
      if (template != null) ...['--template', template],
      databaseName,
    ];

    ProcessResult result = await Process.run(binaries.createdb, args,
        environment: connectionOptions._toEnvironment());

    int exitCode = result.exitCode;
    if (exitCode != 0) {
      throw Exception('createdb exited with code $exitCode.\n${result.stderr}');
    }
  }

  Future<void> dropDatabase(String databaseName, {bool ifExists}) async {
    /*
    dropdb removes a PostgreSQL database.

    Usage:
      dropdb [OPTION]... DBNAME

    Options:
      -e, --echo                show the commands being sent to the server
      -i, --interactive         prompt before deleting anything
      -V, --version             output version information, then exit
      --if-exists               don't report error if database doesn't exist
      -?, --help                show this help, then exit

    Connection options:
      -h, --host=HOSTNAME       database server host or socket directory
      -p, --port=PORT           database server port
      -U, --username=USERNAME   user name to connect as
      -w, --no-password         never prompt for password
      -W, --password            force password prompt
      --maintenance-db=DBNAME   alternate maintenance database
     */
    ifExists ??= false;
    var args = <String>[
      databaseName,
      if (ifExists) '--if-exists',
    ];

    ProcessResult result = await Process.run(binaries.dropdb, args,
        environment: connectionOptions._toEnvironment());

    int exitCode = result.exitCode;
    if (exitCode != 0) {
      throw Exception('dropdb exited with code $exitCode\n${result.stderr}');
    }
  }

  Future<void> dropUser(String userName, {bool ifExists}) async {
    /*
     dropuser removes a PostgreSQL role.

     Usage:
       dropuser [OPTION]... [ROLENAME]

     Options:
       -e, --echo                show the commands being sent to the server
       -i, --interactive         prompt before deleting anything, and prompt for
                                 role name if not specified
       -V, --version             output version information, then exit
       --if-exists               don't report error if user doesn't exist
       -?, --help                show this help, then exit

     Connection options:
       -h, --host=HOSTNAME       database server host or socket directory
       -p, --port=PORT           database server port
       -U, --username=USERNAME   user name to connect as (not the one to drop)
       -w, --no-password         never prompt for password
       -W, --password            force password prompt
     */
    ifExists ??= false;
    var args = <String>[
      userName,
      if (ifExists) '--if-exists',
    ];

    ProcessResult result = await Process.run(binaries.dropuser, args,
        environment: connectionOptions._toEnvironment());

    int exitCode = result.exitCode;
    if (exitCode != 0) {
      throw Exception('dropuser exited with code $exitCode\n${result.stderr}');
    }
  }

  Future<void> grandAllPrivileges(String userName, {String database}) {
    database ??= connectionOptions.database;
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
      "SELECT 1 FROM pg_roles WHERE rolname='${userName.replaceAll("'", "\'")}'",
    ]);

    return results.trim() == '1';
  }

  Future<void> execute(String script, {String database}) async {
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

    return _psql((stdin) {
      stdin.writeln('$script;');
      stdin.close();
    }, database: database);
  }

  Future<void> executeFile(File file, {String database}) async {
    return _psql((stdin) {
      return file.openRead().pipe(stdin);
    }, database: database);
  }

  Future<String> _psql(Function(IOSink) callback, {String database}) async {
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

    var args = <String>[
      '--single-transaction',
      '-v',
      'ON_ERROR_STOP=1',
      if (database != null) ...['--dbname', database],
    ];

    Process process = await Process.start(binaries.psql, args,
        environment: connectionOptions._toEnvironment());

    var stdoutLines = <String>[];
    process.stdout
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .listen((line) {
      stdoutLines.add(line);
      _logger.info(line);
    });

    var stderrLines = <String>[];
    process.stderr
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .listen((line) {
      stderrLines.add(line);
      _logger.severe(line);
    });

    await callback(process.stdin);

    int exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception(
          'psql exited with code $exitCode.\n${stderrLines.join('\n')}');
    }

    return stdoutLines.join('\n');
  }

  Future<String> _runPsql(List<String> args) async {
    var result = await Process.run(binaries.psql, args,
        environment: connectionOptions._toEnvironment());

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

  //TODO(xha): implement
//  Future<String> dump({bool data = true, bool schema = true}) {}
//
//  Future<void> dumpTo(String path, {bool data = true, bool schema = true}) {}

// TODO(xha): Dump to Stream to http/s3/cloud
}

class ConnectionOptions {
  static const defaultPort = 5432;

  final String? hostname;
  final int? port;
  final String? user, password;
  final String database;

  ConnectionOptions(
      {this.hostname,
      this.port,
      required this.user,
      required this.password,
      required this.database});

  factory ConnectionOptions.fromJson(Map<String, dynamic> json) =>
      ConnectionOptions(
        hostname: json['hostname'] as String?,
        port: json['port'] as int?,
        user: json['user'] as String?,
        password: json['password'] as String?,
        database: json['database']! as String,
      );

  Map<String, dynamic> toJson() => {
        'hostname': hostname,
        'port': port,
        'user': user,
        'password': password,
        'database': database,
      };

  Map<String, String> _toEnvironment() {
    var envs = <String, String>{};

    if (hostname != null) {
      envs['PGHOST'] = hostname;
    }

    if (port != null) {
      envs['PGPORT'] = '$port';
    }

    envs['PGDATABASE'] = database;

    if (user != null) {
      envs['PGUSER'] = user;
    }

    if (password != null) {
      envs['PGPASSWORD'] = password;
    }

    return envs;
  }

  ConnectionOptions copyWith(
      {String? hostname,
      int? port,
      String? user,
      String? password,
      String? database}) {
    return ConnectionOptions(
      hostname: hostname ?? this.hostname,
      port: port ?? this.port,
      user: user ?? this.user,
      password: password ?? this.password,
      database: database ?? this.database,
    );
  }
}
