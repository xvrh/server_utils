import '../database.dart';
import 'sql_file_parser.dart';

Future<String> generateSqlFile(SqlFile file, Database database) async {
  var code = StringBuffer();
  for (var import in file.imports) {
    code.writeln(import);
  }

  for (var query in file.queries) {}

  return '$code';
}
