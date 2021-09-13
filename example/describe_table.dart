import 'package:postgres/postgres.dart';
import 'package:server_utils/database.dart';
import 'package:server_utils/src/database/database_io.dart';
import 'package:server_utils/src/test_database.dart';
import 'package:server_utils/src/database/schema/schema.queries.dart';

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
  await runDatabase((connection) async {
    var columns = await connection.describeTable(
        schemaName: 'public', tableName: 'app_user');
    for (var col in columns) {
      print('${col.number} ${col.name} ${col.type} ${col.notNull}');
    }
  });
}
