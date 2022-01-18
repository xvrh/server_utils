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

extension DatabaseExtension on Database {
  Future<T> insert<T>(
    String tableName, {
    required Map<String, dynamic> values,
    required Mapper<T> mapper,
  }) {
    var keys = values.keys.toList();
    if (tableName.contains('"')) {
      throw Exception('Table name is invalid ($tableName)');
    }
    if (keys.any((k) => k.contains('"'))) {
      throw Exception('One column has an invalid name ($keys)');
    }
    return single(
      'insert into "$tableName" '
      '(${keys.map((j) => '"$j"').join(', ')}) '
      'values (${keys.map((k) => '@$k').join(',')}) returning *',
      mapper: mapper,
      args: values,
    );
  }

  Future<T> update<T>(
    String tableName, {
    required Map<String, Object> where,
    required Map<String, Object> set,
    List<String>? clear,
    required Mapper<T> mapper,
  }) {
    if (tableName.contains('"')) {
      throw Exception('Table name is invalid ($tableName)');
    }
    if (where.keys.any((k) => k.contains('"'))) {
      throw Exception(
          'One column has an invalid name (${where.keys.join(',')})');
    }
    if (set.keys.any((k) => k.contains('"'))) {
      throw Exception('One column has an invalid name (${set.keys.join(',')})');
    }
    var updates = <String>[];
    var wheres = <String>[];
    var values = <String, Object>{};
    for (var e in set.entries) {
      updates.add('"${e.key}" = :${e.key}');
      values[e.key] = e.value;
    }
    if (clear != null) {
      for (var e in clear) {
        updates.add('"$e" = null');
      }
    }
    for (var e in where.entries) {
      wheres.add('"${e.key}" = :${e.key}');
      values[e.key] = e.value;
    }

    return single(
      'update "$tableName" set ${updates.join(', ')} where ${wheres.join(' and ')} returning *',
      mapper: mapper,
      args: values,
    );
  }
}
