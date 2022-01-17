import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'postgres.dart';

void startDatabaseServer(Postgres postgres) async {
  if (!stdin.hasTerminal) {
    throw Exception(
        'Run this script from a terminal so it can handle the exit correctly');
  }

  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(print);

  var server = await postgres.server();

  var client = server.client();
  var databases = await client.listDatabases();
  print('Databases: $databases');

  StreamSubscription subscription;
  subscription = ProcessSignal.sigint.watch().listen((event) async {
    exit(0);
  });

  stdin.lineMode = false;
  print('Press Q to exit');
  await for (var bytes in stdin) {
    var line = utf8.decode(bytes);
    if (const ['q', 'Q'].contains(line)) {
      await server.stop();
      await subscription.cancel();
      break;
    }
  }
}
