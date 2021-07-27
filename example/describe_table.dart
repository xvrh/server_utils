import 'package:postgres/postgres.dart';
import 'package:server_utils/postgres.dart';
import 'package:server_utils/src/database/database_io.dart';
import 'package:server_utils/src/test_database.dart';

Future<PostgreSQLConnection> createConnection() async {
  var options = testDatabase.connectionOptions;
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
  var sql =
      //language=sql
      r'''

''';

  await runDatabase((connection) async {
    var result =
        await connection.queryDynamic(sql, args: {'tableName': 'app_user'});

    print(result);
  });
}
