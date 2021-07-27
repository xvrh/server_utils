import 'package:server_utils/postgres.dart';
import 'package:server_utils/src/database/orm/sql_file_generator.dart';
import 'package:server_utils/src/database/orm/sql_file_parser.dart';
import 'package:server_utils/src/test_database.dart';
import 'package:test/test.dart';

void main() {
  late LocalDatabase database;
  setUp(() async {
    database = await testDatabase.createDatabase();
  });

  tearDown(() async {
    await database.drop();
  });

  test('Generate file', () async {
    var migrator =
        Migrator(database.client, ['test/database/orm/data/country']);
    await migrator.migrate();

    var queries = '''
--# import 'path.dart' as abc;    
''';

    var result =
        await database.use((db) => generateSqlFile(parseSqlFile(queries), db));

    expect(result, '''
import 'path.dart' as abc;


''');
  });
}
