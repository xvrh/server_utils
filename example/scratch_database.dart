import 'dart:async';
import 'dart:io';

import 'package:server_utils/database.dart';
import 'package:logging/logging.dart';

void main() async {
  await runZonedGuarded(() async {
    Logger.root
      ..level = Level.ALL
      ..onRecord.listen(print);
    var dataPath = Postgres.temporaryPath;

    try {
      var postgres = Postgres(dataPath);
      var server = await postgres.server();
      print('Server started $dataPath');
      print(Postgres.isDataDirectory(dataPath));
      var client = postgres.client();
      await client.execute('create database machin', transaction: false);
      var databases = await client.listDatabases();
      print('Databases: $databases');
      print('Will stop');
      await server.stop();
      print('Stopped');
    } catch (e, stackTrace) {
      print('Error $e\n$stackTrace');
    } finally {
      var dir = Directory(dataPath);
      dir.deleteSync(recursive: true);
      print(dir.existsSync());
    }
  }, (e, stackTrace) {
    print('Zone error $e');
  });
}
