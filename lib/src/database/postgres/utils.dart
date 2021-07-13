import 'dart:async';
import 'dart:io';

import 'postgres.dart';
import 'package:postgres/postgres.dart';

Future<int> findUnusedPort() async {
  int port;
  ServerSocket socket;
  try {
    socket =
        await ServerSocket.bind(InternetAddress.loopbackIPv6, 0, v6Only: true);
  } on SocketException {
    socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  }
  port = socket.port;
  await socket.close();
  return port;
}

PostgreSQLConnection connectionFromOptions(ConnectionOptions options) =>
    PostgreSQLConnection(options.hostname ?? 'localhost',
        options.port ?? ConnectionOptions.defaultPort, options.database,
        username: options.user, password: options.password);

Directory createRandomDirectory(String basePath) {
  var dataDirectory = Directory(basePath);
  if (!dataDirectory.existsSync()) {
    dataDirectory.createSync(recursive: true);
  }
  return dataDirectory.createTempSync();
}

Future<T> useConnectionOptions<T>(ConnectionOptions options,
    FutureOr<T> Function(PostgreSQLConnection) callback) async {
  var connection = connectionFromOptions(options);
  await connection.open();
  try {
    return await callback(connection);
  } finally {
    await connection.close();
  }
}
