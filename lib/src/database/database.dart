import 'connection_options.dart';
import 'page.dart';
import 'package:postgres/postgres.dart'
    show PostgreSQLExecutionContext, PostgreSQLResult, PostgreSQLResultRow;
import 'package:postgres/postgres.dart';

import 'utils.dart';

typedef Mapper<T> = T Function(PostgreSQLResultRow);

class EntityNotFoundException<T> implements Exception {
  final String sqlQuery;
  final Map<String, dynamic>? args;

  EntityNotFoundException(this.sqlQuery, this.args);

  @override
  String toString() => 'Entity $T not found for request: $sqlQuery ($args)';
}

class TooManyEntityFound<T> implements Exception {
  final int count;
  final String sqlQuery;
  final Map<String, dynamic>? args;

  TooManyEntityFound(this.count, this.sqlQuery, this.args);

  @override
  String toString() =>
      '$count entities $T found for request: $sqlQuery ($args)';
}

class Database {
  final PostgreSQLExecutionContext _connection;

  Database(this._connection);

  static Future<void> use(ConnectionOptions connectionOptions,
      Future Function(Database) callback) async {
    var connection = connectionFromOptions(connectionOptions);
    await connection.open();
    try {
      await callback(Database(connection));
    } finally {
      await connection.close();
    }
  }

  Future<T> scalar<T>(String query, {Map<String, dynamic>? args}) async {
    return single<T>(query, args: args, mapper: (row) => row[0] as T);
  }

  Future<T> single<T>(String sqlQuery,
      {Map<String, dynamic>? args, required Mapper<T> mapper}) async {
    return await _singleOrOptional(sqlQuery,
        args: args,
        mapper: mapper,
        throwsIfEmpty: true,
        throwsIfTooMuch: true) as T;
  }

  Future<T?> singleOrNull<T>(String sqlQuery,
      {Map<String, dynamic>? args, required Mapper<T> mapper}) async {
    return _singleOrOptional(sqlQuery,
        args: args,
        mapper: mapper,
        throwsIfEmpty: false,
        throwsIfTooMuch: true);
  }

  Future<T> first<T>(String sqlQuery,
      {Map<String, dynamic>? args, required Mapper<T> mapper}) async {
    return await _singleOrOptional(sqlQuery,
        args: args,
        mapper: mapper,
        throwsIfEmpty: true,
        throwsIfTooMuch: false) as T;
  }

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
    return mapper(row);
  }

  Future<List<T>> query<T>(String sqlQuery,
      {Map<String, dynamic>? args, required Mapper<T> mapper}) async {
    var results = await _query(sqlQuery, args: args);

    return results.map((r) => mapper(r)).toList();
  }

  Future<List<Map<String, dynamic>>> queryDynamic(String sqlQuery,
      {Map<String, dynamic>? args}) async {
    var results = await _query(sqlQuery, args: args);

    return results.map((r) => r.toColumnMap()).toList();
  }

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

  void cancelTransaction({String? reason}) {
    _connection.cancelTransaction(reason: reason);
  }
}

final _parameterExtractor = RegExp(r'[^:]:([a-z]{1}[a-z0-9_]*)');
