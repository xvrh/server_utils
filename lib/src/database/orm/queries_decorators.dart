import '../database.dart';

extension QueriesDecorator on Database {
  Never q(String sql) {
    // This method serves in the *.queries.dart file to specify the SQL query to execute.
    throw UnimplementedError();
  }

  set testValues(Set<dynamic> values) {}

  set projection(Map<String, Col> cols) {}
}

class Col {
  final bool? nullable;

  const Col({this.nullable});

  @override
  String toString() => 'Col(nullable: $nullable)';
}
