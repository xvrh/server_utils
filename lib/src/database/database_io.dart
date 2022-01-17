import 'package:postgres_pool/postgres_pool.dart';
import 'database.dart';
import 'orm/utils/sql_parser.dart';
import 'page.dart';
import 'utils.dart';

class DatabaseIO implements Database {
  final PostgreSQLExecutionContext _connection;

  DatabaseIO(this._connection);

  static Future<void> use(
      PgEndpoint endpoint, Future Function(Database) callback) async {
    var connection = connectionFromEndpoint(endpoint);
    await connection.open();
    try {
      await callback(DatabaseIO(connection));
    } finally {
      await connection.close();
    }
  }

  @override
  Future<T> scalar<T>(String query, {Map<String, dynamic>? args}) async {
    return single<T>(query, args: args, mapper: (row) => row.values.first as T);
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
    var query = SqlQuery.parse(fmtString);
    var uniqueParameters = query.parameters.map((p) => p.name).toSet();
    assert((args?.length ?? 0) == uniqueParameters.length,
        '$args vs [$uniqueParameters]');
    return _connection.query(_queryString(query), substitutionValues: args);
  }

  @override
  Future<int> execute(String fmtString, {Map<String, dynamic>? args}) async {
    var query = SqlQuery.parse(fmtString);
    assert((args?.length ?? 0) == query.parameters.length);
    var result = await _connection.execute(_queryString(query),
        substitutionValues: args);
    return result;
  }

  String _queryString(SqlQuery query) {
    if (_connection is PostgreSQLExecutionContextWithStandardParameters) {
      return query.body;
    } else {
      return query.bodyWithDartSubstitutions;
    }
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

class PostgreSQLExecutionContextWithStandardParameters {}
