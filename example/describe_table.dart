import 'package:postgres/postgres.dart';
import 'package:server_utils/database.dart';
import 'package:server_utils/src/database/schema/schema_extractor.queries.dart';
import 'example_database.dart';

Future<PostgreSQLConnection> createConnection() async {
  var options =
      exampleDatabaseServer.copyWith(database: exampleDatabaseName).endpoint;
  var connection = connectionFromEndpoint(options);
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
    var columns = await connection.describeTables();
    print('Result $columns');
    for (var col in columns.where((c) => c.tableName == 'cms_page')) {
      print(
          '${col.number} ${col.name} ${col.type} (${col.typeId}) null: ${col.notNull}');
    }
  });
}
