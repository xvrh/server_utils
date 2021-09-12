import 'schema.dart';

class TableHolder implements TableDefinition {
  final String name;
  final columnList = <ColumnDefinition>[];
  final columns = _ColumnsHolder();

  TableHolder(this.name);

  @override
  toString() => name;
}

class _ColumnsHolder implements ColumnDefinitions {
  _ColumnsHolder();
}
