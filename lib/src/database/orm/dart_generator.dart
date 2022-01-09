import 'package:server_utils/src/database/schema/schema.dart';
import 'package:server_utils/src/utils/type.dart';
import 'package:server_utils/src/utils/quick_dart_formatter.dart';
import '../../utils/string.dart';

class DartGenerator {
  Future<String> generateEntities(List<TableDefinition> tables) async {
    var code = StringBuffer('''
// GENERATED-FILE
''');

    for (var table in tables) {
      code.writeln(generateEntity(table));
      code.writeln();
    }
    var resultCode = '$code';
    try {
      resultCode = await formatDartCode(resultCode);
    } catch (e) {
      print('Error while formatting code: $e');
    }
    return resultCode;
  }

  String generateEntity(TableDefinition table) {
    var code = StringBuffer('');

    var className = table.name.words.toUpperCamel();
    var columns = table.columns;

    code.writeln('class $className {');
    for (var column in columns) {
      code.writeln(
          'final ${column.type.dartType}${column.isNullable ? '?' : ''} ${column.name.words.toLowerCamel()};');
    }

    code.writeln('');
    code.writeln('$className({');
    for (var column in columns) {
      code.writeln(
          '${column.isNullable ? '' : 'required '}this.${column.name.words.toLowerCamel()},');
    }
    code.writeln('});');
    code.writeln('');

    code.writeln('factory $className.fromRow(Map<String, dynamic> row) {');
    code.writeln('return $className(');
    for (var column in columns) {
      code.writeln('${column.name.words.toLowerCamel()}: '
          "row['${column.name}']${column.isNullable ? '' : '!'} "
          "as ${column.type.dartType}${column.isNullable ? '?' : ''},");
    }
    code.writeln(');');
    code.writeln('}');
    code.writeln('');

    code.writeln('factory $className.fromJson(Map<String, Object?> json) {');
    code.writeln('return $className(');
    for (var column in columns) {
      var accessor = "json['${column.name.words.toLowerCamel()}']";
      var type = ValueType.fromTypeName(column.type.dartType,
          isNullable: column.isNullable);

      var fromJsonCode =
          type.fromJsonCode(Value(accessor, ObjectType(isNullable: true)));

      code.writeln('${column.name.words.toLowerCamel()}: $fromJsonCode,');
    }
    code.writeln(');');
    code.writeln('}');
    code.writeln('');

    code.writeln(' Map<String, Object?> toJson() {');
    code.writeln('return {');
    for (var column in columns) {
      var type = ValueType.fromTypeName(column.type.dartType,
          isNullable: column.isNullable);

      var toJsonCode = type.toJsonCode(column.name.words.toLowerCamel());
      code.writeln("'${column.name.words.toLowerCamel()}': $toJsonCode,");
    }
    code.writeln('};');
    code.writeln('}');

    code.writeln('}');
    return '$code';
  }

  Future<String> generateCrudFile(List<TableDefinition> tables,
      {required List<String> imports, String? extensionName}) async {
    var code = StringBuffer('''
// GENERATED-FILE

import 'package:server_utils/database.dart';
''');

    for (var import in imports) {
      code.writeln("import '$import';");
    }

    extensionName ??= 'DatabaseCrudExtension';
    code.writeln('extension $extensionName on Database {');
    for (var table in tables) {
      var className = '${table.name.words.toUpperCamel()}Crud';
      code.writeln(
          '$className get ${table.name.words.toLowerCamel()} => $className(this);');
      code.writeln();
    }
    code.writeln('}');

    for (var table in tables) {
      code.writeln(generateCrudForTable(table));
      code.writeln();
    }
    var resultCode = '$code';
    try {
      resultCode = await formatDartCode(resultCode);
    } catch (e) {
      print('Error while formatting code: $e');
    }
    return resultCode;
  }

  String generateCrudForTable(TableDefinition table) {
    var code = StringBuffer('');

    var className = '${table.name.words.toUpperCamel()}Crud';
    var columns = table.columns;
    var primaryKeys = columns.where((c) => c.isPrimaryKey).toList();

    code.writeln('''
class $className {
  final Database _database;

  $className(this._database);    
''');

    _findCode(code, table, primaryKeys);
    _insertCode(code, table);
    _updateCode(code, table);
    _deleteCode(code, table, primaryKeys);

    code.writeln('}');
    return '$code';
  }

  void _findCode(StringBuffer code, TableDefinition table,
      List<ColumnDefinition> primaryKeys) {
    var entityName = table.name.words.toUpperCamel();

    code.writeln(
        'Future<$entityName> find(${primaryKeys.map((p) => '${p.type.dartType} ${p.name.words.toLowerCamel()}').join(', ')}) {');
    code.writeln('return _database.single(');
    code.writeln('  //language=sql');

    var where = primaryKeys
        .map((p) =>
            '${p.name} = :${p.name.words.toLowerCamel()}::${p.type.postgresType}')
        .join(' and ');
    code.writeln("'select * from ${table.name} where $where',");
    code.writeln('  //language=none');
    code.writeln('args: {');
    for (var p in primaryKeys) {
      code.writeln("'${p.name}': ${p.name.words.toLowerCamel()},");
    }
    code.writeln('},');
    code.writeln('mapper: $entityName.fromRow,');
    code.writeln(');');
    code.writeln('}');
    code.writeln('');
  }

  void _insertCode(StringBuffer code, TableDefinition table) {
    var entityName = table.name.words.toUpperCamel();

    code.writeln('Future<$entityName> insert({');
    for (var column in table.columns) {
      var fieldName = column.name.words.toLowerCamel();
      if (column.isNullable || column.defaultValue != null) {
        var type = column.type.dartType;
        if (type == 'dynamic') {
          type = 'Object';
        }
        type += '?';
        var comment = '';
        if (column.defaultValue != null) {
          comment = '/* ${column.defaultValue} */';
        }
        code.writeln('$type $fieldName $comment,');
      } else {
        code.writeln('required ${column.type.dartType} $fieldName,');
      }
    }
    code.writeln('}) {');
    code.writeln("return _database.insert('${table.name}',");
    code.writeln('values: {');
    for (var column in table.columns) {
      var variableName = column.name.words.toLowerCamel();
      if (column.isNullable || column.defaultValue != null) {
        code.writeln('if ($variableName != null)');
      }
      code.writeln("'${column.name}': $variableName,");
    }
    code.writeln('},');
    code.writeln('mapper: $entityName.fromRow,');
    code.writeln(');');
    code.writeln('}');
    code.writeln('');
  }

  void _updateCode(StringBuffer code, TableDefinition table) {
    var entityName = table.name.words.toUpperCamel();

    code.writeln('Future<$entityName> updateFields() {');
    code.writeln('throw UnimplementedError();');
    code.writeln('}');
    code.writeln('');
    code.writeln('Future<$entityName> updateEntity($entityName entity) {');
    code.writeln('throw UnimplementedError();');
    code.writeln('}');
    code.writeln('');
  }

  void _deleteCode(StringBuffer code, TableDefinition table,
      List<ColumnDefinition> primaryKeys) {
    code.writeln(
        'Future<int> delete(${primaryKeys.map((p) => '${p.type.dartType} ${p.name.words.toLowerCamel()}').join(', ')}) {');
    code.writeln('return _database.execute(');
    code.writeln('  //language=sql');
    var where = primaryKeys
        .map((p) =>
            '${p.name} = :${p.name.words.toLowerCamel()}::${p.type.postgresType}')
        .join(' and ');
    code.writeln("'delete from ${table.name} where $where',");
    code.writeln('  //language=none');
    code.writeln('args: {');
    for (var p in primaryKeys) {
      code.writeln("'${p.name}': ${p.name.words.toLowerCamel()},");
    }
    code.writeln('},');
    code.writeln(');');
    code.writeln('}');
    code.writeln('');
  }
}
