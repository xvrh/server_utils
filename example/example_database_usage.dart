import 'package:postgres/postgres.dart';
import 'package:server_utils/database.dart';
import 'package:server_utils/src/test_database.dart';

import 'example_database_builder.dart';
import 'select.queries.dart';

Future<PostgreSQLConnection> createConnection() async {
  var options = testDatabaseSuperuser
      .copyWith(database: exampleDatabaseName)
      .connectionOptions;
  var connection = connectionFromOptions(options);
  await connection.open();

  return connection;
}

Future runDatabase(Function(Database) callback) async {
  var connection = await createConnection();
  try {
    await callback(DatabaseIO(connection));
  } finally {
    await connection.close();
  }
}

void main() async {
  print('Start');
  var stopwatch = Stopwatch()..start();
  await runDatabase((db) async {
    var users = await db.allNames();
    print(users);

    var user = await db.findUserByEmail('not found');
    print(user);

    var found = await db.findUserByEmail('info@xaha.dev');
    print(found);

    var belgium = await db.queryByCountry('BE').list;
    print(belgium);
  });
  print('Run in ${stopwatch.elapsed}');
}
