import 'package:server_utils/database.dart';
import 'package:server_utils/src/database/orm/queries_generator.dart';
import 'package:server_utils/src/database/schema/schema_extractor.dart';
import 'package:server_utils/src/test_database.dart';
import 'package:test/test.dart';

void main() {
  late LocalDatabase database;
  setUp(() async {
    database = await testDatabaseSuperuser.createDatabase();
  });

  tearDown(() async {
    await database.drop();
  });

  test('Return type parser (1)', () {
    var type = ReturnType('List<XX>');
    expect(type.returnType, 'Future<List<XX>>');
    expect(type.methodCall, '.list');
    expect(type.innerType, 'XX');
  });

  test('Return type parser (2)', () {
    var type = ReturnType('List<String?>');
    expect(type.returnType, 'Future<List<String?>>');
    expect(type.methodCall, '.list');
    expect(type.innerType, 'String?');
    expect(type.innerTypeWithoutNullability, 'String');
  });

  test('Return type parser (3)', () {
    var type = ReturnType('String?');
    expect(type.returnType, 'Future<List<String?>>');
    expect(type.methodCall, '.list');
    expect(type.innerType, 'String?');
    expect(type.innerTypeWithoutNullability, 'String');
  });

  test('Generate file', () async {
    var migrator =
        Migrator(database.client, ['test/database/orm/data/country']);
    await migrator.migrate();

    var queries = '''
--@import 'path.dart' as abc;

/***
Query<abc.Country> allCountries()
***/
select * from country;

/***
Query<abc.Country> allCountries2()
***/
-- detect we are reading all columns from entity
select * from country;
''';

    var result = await database.useConnection((db) async {
      var dbSchema = await SchemaExtractor(DatabaseIO(db)).schema();
      var generator = QueriesGenerator(dbSchema, PostgresQueryEvaluator(db));
      return generator.generate(queries, filePath: 'my_queries');
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
