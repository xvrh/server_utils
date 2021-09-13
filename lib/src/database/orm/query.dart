import 'package:server_utils/src/database/database.dart';
import 'package:server_utils/src/database/page.dart';

class Query<TReturn> {
  final Database database;
  final String sql;
  final Map<String, dynamic> arguments;
  final Mapper<TReturn> mapper;

  Query(this.database, this.sql,
      {required this.arguments, required this.mapper});

  Query.singleColumn(this.database, this.sql, {required this.arguments})
      : mapper = _singleColumnMapper;

  static T _singleColumnMapper<T>(Map<String, dynamic> row) {
    return row.values.first as T;
  }

  Future<TReturn> get single {
    return database.single(sql, mapper: mapper, args: arguments);
  }

  Future<TReturn?> get singleOrNull {
    return database.singleOrNull(sql, mapper: mapper, args: arguments);
  }

  Future<List<TReturn>> get list {
    return database.query(sql, mapper: mapper, args: arguments);
  }

  Future<Page<TReturn>> page(PageRequest page) {
    return database.queryPage(sql,
        mapper: mapper, args: arguments, pageRequest: page);
  }
}
