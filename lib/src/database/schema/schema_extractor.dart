import 'schema.dart';

import '../database.dart';
import 'schema_extractor.queries.dart';
import 'package:collection/collection.dart';

class SchemaExtractor {
  final Database database;

  SchemaExtractor(this.database);

  Future<DatabaseSchema> schema(
      {String? schemaName, bool Function(String)? tableFilter}) async {
    tableFilter ??= (String table) => !table.startsWith('_');
    schemaName ??= 'public';

    var tableNames = await database.tablesForSchema(schemaName: schemaName);
    var allColumns = await database.columnsForSchema(schemaName: schemaName);
    var primaryKeys =
        await database.constraintsForSchema(schemaName: schemaName);
    var domains = await database.domainsForSchema(schemaName: schemaName);

    var results = <TableDefinition>[];
    for (var tableName in tableNames.where(tableFilter)) {
      var columnList = <ColumnDefinition>[];
      var tableHolder = TableDefinition(tableName, columnList);
      results.add(tableHolder);

      for (var column in allColumns.where((c) => c.tableName == tableName)) {
        var isPrimaryKey = primaryKeys.any((c) =>
            c.tableName == tableName && c.columnName == column.columnName);

        var domain =
            domains.firstWhereOrNull((e) => e.name == column.domainName);
        var isNullable = column.isNullable;
        if (domain != null && domain.notNull) {
          isNullable = false;
        }

        var field = ColumnDefinition(
          column.columnName,
          type: DataType.fromPostgresName(column.dataType),
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: column.columnDefault ?? domain?.defaultValue,
          domain: domain?.name,
        );
        columnList.add(field);
      }
    }

    return DatabaseSchema(results);
  }

  //TODO(xha): extracts views & functions
}
