import 'page.dart';
import 'schema/schema.dart';

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
      required PageRequest<T> pageRequest,
      required Mapper<T> mapper});

  Future<int> execute(String fmtString, {Map<String, dynamic> args});

  Future<T> transaction<T>(Future<T> Function(Database) callback);

  void cancelTransaction({String reason});
}

extension DatabaseExtension on Database {
  Future<T> insert<T>(
    TableDefinition table, {
    required Map<String, dynamic> values,
    required Mapper<T> mapper,
  }) {
    var tableName = table.name;
    var keys = values.keys.toList();
    if (tableName.contains('"')) {
      throw Exception('Table name is invalid ($tableName)');
    }
    if (keys.any((k) => k.contains('"'))) {
      throw Exception('One column has an invalid name ($keys)');
    }
    var valueVariables = <String>[];
    for (var key in keys) {
      var column = table[key];
      if (column == null) {
        throw Exception(
            'Column [$key] not found. Available (${table.columns.map((c) => c.name).join(', ')})');
      }
      valueVariables.add(
          ':$key::${column.enumDefinition?.name ?? column.type.postgresType}');
    }

    return single(
      'insert into "$tableName" '
      '(${keys.map((j) => '"$j"').join(', ')}) '
      'values (${valueVariables.join(',')}) returning *',
      mapper: mapper,
      args: values,
    );
  }

  Future<T> update<T>(
    TableDefinition table, {
    required Map<String, Object> where,
    required Map<String, Object> set,
    List<String>? clear,
    required Mapper<T> mapper,
  }) {
    var tableName = table.name;
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
      var column = table.columns.firstWhere((c) => c.name == e.key,
          orElse: () => throw Exception('Column [${e.key}] not found.'));
      var enumDefinition = column.enumDefinition;
      if (enumDefinition != null) {
        updates.add(
            '"${e.key}" = ' "'${e.value.toString().replaceAll("'", "''")}'");
      } else {
        updates.add(
            '"${e.key}" = :${e.key}:${column.type.typeString}::${column.type.postgresType}');
        values[e.key] = e.value;
      }
    }
    if (clear != null) {
      for (var e in clear) {
        updates.add('"$e" = null');
      }
    }
    for (var e in where.entries) {
      var column = table.columns.firstWhere((c) => c.name == e.key,
          orElse: () => throw Exception('Column where [${e.key}] not found.'));
      wheres.add(
          '"${e.key}" = :${e.key}:${column.type.typeString}::${column.enumDefinition?.name ?? column.type.postgresType}');
      values[e.key] = e.value;
    }
    if (updates.isEmpty) {
      var firstWhere = where.keys.first;
      updates.add('$firstWhere = $firstWhere');
    }
    return single(
      'update "$tableName" set ${updates.join(', ')} where ${wheres.join(' and ')} returning *',
      mapper: mapper,
      args: values,
    );
  }
}
