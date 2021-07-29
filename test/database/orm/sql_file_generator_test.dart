import 'package:server_utils/database.dart';
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

--# allCountries -> abc.Country
select * from country;

--# allCountries2
-- detect we are reading all columns from entity
select * from country;
''';

    var result = await database.useConnection((db) {
      var generator = SqlFileGenerator(db);
      return generator.generate(parseSqlFile(queries), fileName: 'my_queries');
    });

    expect(result, """
// GENERATED-CODE: do not edit
// Code is generated from my_queries.sql
import 'package:server_utils/database.dart';
import 'path.dart' as abc;

extension MyQueries on Database {
  Query<abc.Country> allCountries() {
    return Query<abc.Country>(r'''
select * from country;
''', {});
  }
  
  Query<Country> allCountries2() {
    return Query<Country>(r'''
-- detect we are reading all columns from entity
select * from country;
''', {});
  }
}
""");
  });
}
