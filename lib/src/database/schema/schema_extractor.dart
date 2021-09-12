import 'schema.dart';
import 'schema_holder.dart';

import '../database.dart';

class SchemaExtractor {
  final Database database;

  SchemaExtractor(this.database);

  Future<List<TableDefinition>> extractTables(
      {String? schemaName, bool Function(String)? tableFilter}) async {
    tableFilter ??= (String table) => !table.startsWith('_');
    schemaName ??= 'public';

    var tableNames = await database.query(_tableNamesQuery,
        args: {'0': schemaName}, mapper: (r) => r[0] as String);

    var allColumns = await database.query(_columnsQuery,
        args: {'0': schemaName}, mapper: _Column.fromRow);

    var primaryKeys = await database.query(_contraintsQuery,
        args: {'0': schemaName}, mapper: _Constraint.fromRow);

    var results = <TableHolder>[];
    for (var tableName in tableNames.where(tableFilter)) {
      var tableHolder = TableHolder(tableName);
      results.add(tableHolder);

      for (var column in allColumns.where((c) => c.tableName == tableName)) {
        var isPrimaryKey = primaryKeys.any((c) =>
            c.tableName == tableName && c.columnName == column.columnName);

        var field = ColumnDefinition.forType(column.dataType, column.columnName,
            isNullable: column.isNullable,
            isPrimaryKey: isPrimaryKey,
            defaultValue: column.columnDefault);
        tableHolder.columnList.add(field);
      }
    }

    return results;
  }

  //TODO(xha): extracts views & functions
}

class _Column {
  final String tableName, columnName, columnDefault, dataType;
  final bool isNullable;

  _Column(
      {this.tableName,
      this.columnName,
      this.columnDefault,
      this.dataType,
      this.isNullable});

  static _Column fromRow(Row row) {
    return _Column(
      tableName: row['table_name'],
      columnName: row['column_name'],
      columnDefault: row['column_default'],
      dataType: row['data_type'],
      isNullable: row['is_nullable'],
    );
  }
}

class _Constraint {
  final String tableCatalog, tableName, columnName, constraintName;
  final int ordinalPosition;

  _Constraint(
      {this.tableCatalog,
      this.tableName,
      this.columnName,
      this.constraintName,
      this.ordinalPosition});

  static _Constraint fromRow(Row row) {
    return _Constraint(
      tableCatalog: row['table_catalog'],
      tableName: row['table_name'],
      columnName: row['column_name'],
      constraintName: row['constraint_name'],
      ordinalPosition: row['ordinal_position'],
    );
  }
}
