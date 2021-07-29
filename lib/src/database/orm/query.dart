import 'package:server_utils/src/database/page.dart';

class Query<TReturn> {
  final String sql;
  final Map<String, dynamic> arguments;

  Query(this.sql, this.arguments);

  Future<TReturn> get single => throw UnimplementedError();
  Future<TReturn?> get singleOrNull => throw UnimplementedError();
  Future<List<TReturn>> get list => throw UnimplementedError();
  Future<Page<TReturn>> page(PageRequest page) => throw UnimplementedError();
}
