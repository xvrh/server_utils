import 'connection_options.dart';
import 'database.dart';
import 'page.dart';
import 'package:postgres/postgres.dart'
    show PostgreSQLExecutionContext, PostgreSQLResult;
import 'package:postgres/postgres.dart';

import 'utils.dart';

class DatabaseIO implements Database {
  final PostgreSQLExecutionContext _connection;

  DatabaseIO(this._connection);

  static Future<void> use(ConnectionOptions connectionOptions,
      Future Function(Database) callback) async {
    var connection = connectionFromOptions(connectionOptions);
    await connection.open();
    try {
      await callback(DatabaseIO(connection));
    } finally {
      await connection.close();
    }
  }

  @override
  Future<T> scalar<T>(String query, {Map<String, dynamic>? args}) async {
    return single<T>(query, args: args, mapper: (row) => row[0] as T);
  }

  @override
  Future<T> single<T>(String sqlQuery,
      {Map<String, dynamic>? args, required Mapper<T> mapper}) async {
    return await _singleOrOptional(sqlQuery,
        args: args,
        mapper: mapper,
        throwsIfEmpty: true,
        throwsIfTooMuch: true) as T;
  }

  @override
  Future<T?> singleOrNull<T>(String sqlQuery,
      {Map<String, dynamic>? args, required Mapper<T> mapper}) async {
    return _singleOrOptional(sqlQuery,
        args: args,
        mapper: mapper,
        throwsIfEmpty: false,
        throwsIfTooMuch: true);
  }

  @override
  Future<T> first<T>(String sqlQuery,
      {Map<String, dynamic>? args, required Mapper<T> mapper}) async {
    return await _singleOrOptional(sqlQuery,
        args: args,
        mapper: mapper,
        throwsIfEmpty: true,
        throwsIfTooMuch: false) as T;
  }

  @override
  Future<T?> firstOrNull<T>(String sqlQuery,
      {Map<String, dynamic>? args, required Mapper<T> mapper}) async {
    return _singleOrOptional(sqlQuery,
        args: args,
        mapper: mapper,
        throwsIfEmpty: false,
        throwsIfTooMuch: false);
  }

  Future<T?> _singleOrOptional<T>(String sqlQuery,
      {Map<String, dynamic>? args,
      required Mapper<T> mapper,
      required bool throwsIfEmpty,
      required bool throwsIfTooMuch}) async {
    var results = await _query(sqlQuery, args: args);
    if (results.isEmpty) {
      if (throwsIfEmpty) {
        throw EntityNotFoundException<T>(sqlQuery, args);
      } else {
        return null;
      }
    } else if (results.length > 1) {
      if (throwsIfTooMuch) {
        throw TooManyEntityFound(results.length, sqlQuery, args);
      }
    }

    var row = results.first;
    return mapper(row.toColumnMap());
  }

  @override
  Future<List<T>> query<T>(String sqlQuery,
      {Map<String, dynamic>? args, required Mapper<T> mapper}) async {
    var results = await _query(sqlQuery, args: args);

    return results.map((r) => mapper(r.toColumnMap())).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> queryDynamic(String sqlQuery,
      {Map<String, dynamic>? args}) async {
    var results = await _query(sqlQuery, args: args);

    return results.map((r) => r.toColumnMap()).toList();
  }

  @override
  Future<Page<T>> queryPage<T>(String sqlQuery,
      {Map<String, dynamic>? args,
      required PageRequest pageRequest,
      required Mapper<T> mapper}) async {
    var pageSize = pageRequest.pageSize;
    var pagedQuery = '''
      select * from ($sqlQuery) as p
      order by ${pageRequest.sort.field} ${sortDirectionToString(pageRequest.sort.direction)} 
      limit $pageSize offset ${pageRequest.offset}''';
    var results = await query(pagedQuery, args: args, mapper: mapper);

    int totalLength;
    if (results.length >= pageSize) {
      totalLength =
          await scalar('select count(*) from ($sqlQuery) as p', args: args);
    } else {
      totalLength = pageRequest.offset + results.length;
    }

    return Page(pageRequest: pageRequest, totalLength: totalLength)
      ..entities.addAll(results);
  }

  Future<PostgreSQLResult> _query(String fmtString,
      {Map<String, dynamic>? args}) {
    return _connection.query(
        _replaceNormalParametersWithSubstitution(fmtString),
        substitutionValues: args);
  }

  @override
  Future<int> execute(String fmtString, {Map<String, dynamic>? args}) async {
    var result = await _connection.execute(
        _replaceNormalParametersWithSubstitution(fmtString),
        substitutionValues: args);
    return result;
  }

  // Replace parameter of the form :<parameter> which are recognized by the IDE
  // to parameters of the form @<parameter> which are used by the postgres Dart library.
  String _replaceNormalParametersWithSubstitution(String query) {
    return query.replaceAllMapped(_parameterExtractor, (match) {
      return '@${match.group(1)}';
    });
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Database) callback) async {
    var postgresConnection = _connection as PostgreSQLConnection;
    late T result;
    await postgresConnection.transaction((context) async {
      var innerDatabase = DatabaseIO(context);
      result = await callback(innerDatabase);
    });
    return result;
  }

  @override
  void cancelTransaction({String? reason}) {
    _connection.cancelTransaction(reason: reason);
  }
}

final _parameterExtractor = RegExp(r'[^:]:([a-z]{1}[a-z0-9_]*)');
