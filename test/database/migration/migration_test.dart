import 'package:server_utils/database.dart';
import 'package:test/test.dart';
import '../utils.dart';

final _testDataPath = 'test/database/migration/data';

void main() {
  var testUtils = DatabaseTestUtils();

  test('Can apply migration from folder', () async {
    var database = testUtils.database;
    var migrator = Migrator.fromClient(database.client, ['$_testDataPath/1']);

    await migrator.migrate();

    await database.use((db) async {
      var result =
          await db.queryDynamic("select * from company where name like '%ik%'");
      expect(result[0]['name'], equals('Nike'));
    });
  });

  test('Can create northwind database', () async {
    var database = testUtils.database;
    var migrator = Migrator.fromClient(
        database.client, ['test/database/migration/data/northwind']);

    await migrator.migrate();

    await database.use((db) async {
      var result = await db.queryDynamic(
          'select * from customers where customer_id = @customerId',
          args: {'customerId': 'ALFKI2'});
      expect(result[0]['company_name'], equals('Alfreds Futterkiste 2'));
    });
  });

  test('Continue migration from existing database', () async {
    var database = testUtils.database;
    await Migrator.fromClient(database.client, ['$_testDataPath/2/1'])
        .migrate();
    await database.use((db) async {
      var result = await db.queryDynamic('select count(*) c from film');
      expect(result[0]['c'], greaterThan(0));
    });

    await Migrator.fromClient(database.client, ['$_testDataPath/2']).migrate();

    await database.use((db) async {
      var result = await db.scalar<int>('select count(*) from film');
      expect(result, greaterThan(100));

      var actors = await db.scalar<int>('select count(*) from actor');
      expect(actors, greaterThan(99));
    });

    await database.use((db) async {
      var result =
          await db.queryDynamic('select count(*) as c from _migration_history');
      expect(result[0]['c'], equals(3));
    });
  });
}
