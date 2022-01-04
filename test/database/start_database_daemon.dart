import 'dart:io';

import 'package:logging/logging.dart';
import '../../example/example_database.dart';

void main() async {
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  var server = await exampleDatabaseSuperUser.server();

  var client = server.client();
  var databases = await client.listDatabases();
  print('Databases: $databases');
  print('Container: ${server.name}');

  exit(0);
}
