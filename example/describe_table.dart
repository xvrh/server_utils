import 'package:postgres/postgres.dart';
import 'package:server_utils/database.dart';
import 'package:server_utils/src/database/schema/schema_extractor.queries.dart';

import 'example_database.dart';
import 'example_database_builder.dart';

Future<PostgreSQLConnection> createConnection() async {
  var options =
      exampleDatabaseSuperUser.copyWith(database: exampleDatabaseName).endpoint;
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
    var columns = await connection.describeTable(tableName: 'page');
    print('Result $columns');
    for (var col in columns) {
      print(
          '${col.number} ${col.name} ${col.type} (${col.typeId}) null: ${col.notNull}');
    }
  });
}
