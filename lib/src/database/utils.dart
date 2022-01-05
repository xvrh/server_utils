import 'dart:async';
import 'dart:io';

import 'package:postgres_pool/postgres_pool.dart';

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

PostgreSQLConnection connectionFromEndpoint(PgEndpoint endpoint) =>
    PostgreSQLConnection(endpoint.host, endpoint.port, endpoint.database,
        username: endpoint.username, password: endpoint.password);

Directory createRandomDirectory(String basePath) {
  var dataDirectory = Directory(basePath);
  if (!dataDirectory.existsSync()) {
    dataDirectory.createSync(recursive: true);
  }
  return dataDirectory.createTempSync();
}

Future<T> useEndpoint<T>(PgEndpoint endpoint,
    FutureOr<T> Function(PostgreSQLConnection) callback) async {
  var connection = connectionFromEndpoint(endpoint);
  await connection.open();
  try {
    return await callback(connection);
  } finally {
    await connection.close();
  }
}
