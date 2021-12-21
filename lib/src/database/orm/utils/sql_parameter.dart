import 'package:server_utils/src/database/schema/schema.dart' show DataType;
export 'package:server_utils/src/database/schema/schema.dart' show DataType;

/*class SqlParameter {
  final String name;
  final DataType? type;

  SqlParameter(this.name, this.type);

  @override
  int get hashCode => Object.hash(name, type);

  @override
  bool operator ==(other) =>
      other is SqlParameter && other.name == name && other.type == type;

  @override
  String toString() => 'SqlParameter($name, $type)';

  static final _extractor = RegExp(
      r'[^:]:([a-z][a-z0-9_]*)((?<colons>::?)(?<type>[a-z][a-z0-9]+(\[\])?))?',
      caseSensitive: false);
  static final _replacer = RegExp(r'[^:]:([a-z][a-z0-9_]*)');

  static List<SqlParameter> extract(String sqlQuery) {
    var matches = _extractor.allMatches(sqlQuery);
    var parameters = <SqlParameter>[];
    for (var match in matches) {
      var name = match.group(1)!;
      var type = match.namedGroup('type');

      DataType? dataType;
      if (type != null) {
        dataType = DataType.fromPostgresName(type);
        var colons = match.namedGroup('colons')!;
        if (colons.length == 1) {
          throw Exception('Use double colon (::) syntax to bind type');
        }
      }

      parameters.add(SqlParameter(name, dataType));
    }
    return parameters;
  }

  // Replace parameter of the form :<parameter> which are recognized by the IDE
  // to parameters of the form @<parameter> which are used by the postgres Dart library.
  static String replaceParametersWithSubstitution(String query) {
    return query.replaceAllMapped(_replacer, (match) {
      return '@${match.group(1)}';
    });
  }
}
*/
