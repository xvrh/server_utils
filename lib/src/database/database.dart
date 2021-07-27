import 'page.dart';

typedef Mapper<T> = T Function(Map<String, dynamic>);

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

abstract class Database {
  Future<T> scalar<T>(String query, {Map<String, dynamic> args});

  Future<T> single<T>(String sqlQuery,
      {Map<String, dynamic> args, required Mapper<T> mapper});

  Future<T?> singleOrNull<T>(String sqlQuery,
      {Map<String, dynamic> args, required Mapper<T> mapper});

  Future<T> first<T>(String sqlQuery,
      {Map<String, dynamic> args, required Mapper<T> mapper});

  Future<T?> firstOrNull<T>(String sqlQuery,
      {Map<String, dynamic> args, required Mapper<T> mapper});

  Future<List<T>> query<T>(String sqlQuery,
      {Map<String, dynamic> args, required Mapper<T> mapper});

  Future<List<Map<String, dynamic>>> queryDynamic(String sqlQuery,
      {Map<String, dynamic> args});

  Future<Page<T>> queryPage<T>(String sqlQuery,
      {Map<String, dynamic> args,
      required PageRequest pageRequest,
      required Mapper<T> mapper});

  Future<int> execute(String fmtString, {Map<String, dynamic> args});

  Future<T> transaction<T>(Future<T> Function(Database) callback);

  void cancelTransaction({String reason});
}
