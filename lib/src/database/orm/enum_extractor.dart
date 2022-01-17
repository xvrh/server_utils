import '../database.dart';
import '../schema/schema.dart';

class EnumExtractor {
  final Database database;
  final DatabaseSchema schema;

  EnumExtractor(this.database, this.schema);

  Future<EnumDefinition> extractTable(String table, {String? query}) async {
    query ??= 'select * from "$table"';

    var tableDefinition = schema.tables.firstWhere((t) => t.name == table);
    var rows = await database.queryDynamic(query);

    return EnumDefinition(
        tableDefinition,
        rows.map((r) {
          return {
            for (var e in r.entries) tableDefinition[e.key]!: e.value,
          };
        }).toList());
  }
}

class EnumDefinition {
  final TableDefinition table;
  final List<Map<ColumnDefinition, Object?>> rows;

  EnumDefinition(this.table, this.rows);

  ColumnDefinition get primaryKey =>
      table.columns.singleWhere((c) => c.isPrimaryKey);
}
