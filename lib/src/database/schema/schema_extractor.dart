import 'package:collection/collection.dart';
import '../database.dart';
import 'schema.dart';
import 'schema_extractor.queries.dart';

class SchemaExtractor {
  static const userDefinedType = 'USER-DEFINED';

  final Database database;

  SchemaExtractor(this.database);

  Future<DatabaseSchema> schema(
      {String? schemaName, bool Function(String)? tableFilter}) async {
    tableFilter ??= (String table) => !table.startsWith('_');
    schemaName ??= 'public';

    var tableNames = await database.tablesForSchema(schemaName: schemaName);
    var allColumns = await database.columnsForSchema(schemaName: schemaName);
    var tableDescriptions =
        await database.describeTables(schemaName: schemaName);
    var primaryKeys =
        await database.primaryKeysForSchema(schemaName: schemaName);
    var foreignKeys =
        await database.foreignKeysForSchema(schemaName: schemaName);
    var domains = await database.domainsForSchema(schemaName: schemaName);
    var enums = await database.valuesForEnums(schemaName: schemaName);
    var userDefinedTypes =
        await database.userDefinedTypes(schemaName: schemaName);

    var enumDefinitions = <EnumDefinition>[];
    for (var enumName in enums.map((e) => e.name).toSet()) {
      var def = EnumDefinition(enumName,
          enums.where((e) => e.name == enumName).map((e) => e.value).toList(),
          userType: userDefinedTypes.singleWhere((t) => t.name == enumName));
      enumDefinitions.add(def);
    }

    var tableDefinitions = <TableDefinition>[];
    for (var tableName in tableNames.where(tableFilter)) {
      var columnList = <ColumnDefinition>[];
      var tableHolder = TableDefinition(tableName, columnList);
      tableDefinitions.add(tableHolder);

      for (var column in allColumns.where((c) => c.tableName == tableName)) {
        var columnDescription = tableDescriptions.firstWhere(
            (e) => e.tableName == tableName && e.name == column.columnName);
        var isPrimaryKey = primaryKeys.any((c) =>
            c.tableName == tableName && c.columnName == column.columnName);
        var foreignKey = foreignKeys.firstWhereOrNull((c) =>
            c.tableName == tableName && c.columnName == column.columnName);

        var domain =
            domains.firstWhereOrNull((e) => e.name == column.domainName);
        var isNullable = column.isNullable;
        if (domain != null && domain.notNull) {
          isNullable = false;
        }

        EnumDefinition? enumDefinition;
        var dataTypeName = column.dataType;
        DataType dataType;
        if (dataTypeName == userDefinedType) {
          dataType = DataType.text;
          enumDefinition = enumDefinitions
              .singleWhere((e) => e.name == columnDescription.type);
        } else {
          dataType = DataType.fromPostgresName(dataTypeName);
        }

        var field = ColumnDefinition(
          column.columnName,
          type: dataType,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: column.columnDefault ?? domain?.defaultValue,
          domain: domain?.name,
          foreignTable: foreignKey?.foreignTableName,
          enumDefinition: enumDefinition,
        );
        columnList.add(field);
      }
    }

    return DatabaseSchema(tableDefinitions, enumDefinitions);
  }

  //TODO(xha): extracts views & functions
}
