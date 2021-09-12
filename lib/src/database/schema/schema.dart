import 'package:server_utils/src/database/orm/schema.dart';

abstract class TableDefinition {
  String get name;

  ColumnDefinitions get columns;

  List<ColumnDefinition> get columnList;
}

abstract class ColumnDefinitions {}

class ColumnDefinition<TField> {
  final DataType<TField> type;
  final String postgresType;
  final String name;
  final bool isNullable, isPrimaryKey;
  final String? defaultValue;

  const ColumnDefinition(this.name,
      {required this.type,
      required this.postgresType,
      bool? isNullable,
      bool? isPrimaryKey,
      this.defaultValue})
      : isNullable = isNullable ?? true,
        isPrimaryKey = isPrimaryKey ?? false;

  static ColumnDefinition forType(String typeName, String name,
      {bool? isNullable, bool? isPrimaryKey, String? defaultValue}) {
    var type = DataType.fromPostgresName(typeName);
    if (type is DataType<int>) {
      return ColumnDefinition<int>(name,
          type: type,
          postgresType: typeName,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    } else if (type is DataType<double>) {
      return ColumnDefinition<double>(name,
          type: type,
          postgresType: typeName,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    } else if (type is DataType<String>) {
      return ColumnDefinition<String>(name,
          type: type,
          postgresType: typeName,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    } else if (type is DataType<bool>) {
      return ColumnDefinition<bool>(name,
          type: type,
          postgresType: typeName,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    } else if (type is DataType<DateTime>) {
      return ColumnDefinition<DateTime>(name,
          type: type,
          postgresType: typeName,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    } else {
      return ColumnDefinition<dynamic>(name,
          type: type,
          postgresType: typeName,
          isNullable: isNullable,
          isPrimaryKey: isPrimaryKey,
          defaultValue: defaultValue);
    }
  }

  Type get dartType => type.type;

  @override
  toString() => name;
}
