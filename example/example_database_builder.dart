import 'dart:developer' as dev;
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';
import 'package:server_utils/database.dart';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';
import 'package:stream_transform/stream_transform.dart';

import 'example_database.dart';

const exampleDatabaseName = 'example_database';

void main() async {
  // Change the level in "afterReload" function
  Logger.root.onRecord.listen(print);
  await _afterReload();

  var observatoryUri = (await dev.Service.getInfo()).serverUri;
  if (observatoryUri != null) {
    var serviceClient = await vmServiceConnectUri(
        convertToWebSocketUrl(serviceProtocolUrl: observatoryUri).toString(),
        log: StdoutLog());
    var vm = await serviceClient.getVM();
    var mainIsolate = vm.isolates!.first;

    Watcher(Directory.current.path)
        .events
        .throttle(const Duration(milliseconds: 1000))
        .listen((_) async {
      await serviceClient.reloadSources(mainIsolate.id!);
      await _afterReload();

      print('Hot reloaded ${DateTime.now()}');
    });
  } else {
    print(
        'You need to pass `--enable-vm-service --disable-service-auth-codes` to enable hot reload');
  }

  await runDatabaseBuilder(
    exampleDatabaseSuperUser,
    exampleDatabaseName,
    migrations: ['example/test_database'],
    queries: ['example/**.queries.sql'],
    afterCreate: _afterCreate,
    afterRefresh: _afterRefresh,
  );
}

Future<void> _afterReload() async {
  Logger.root.level = Level.ALL;
}

Future<void> _afterCreate(PostgreSQLConnection connection) async {}

Future<void> _afterRefresh(PostgreSQLConnection connection) async {
  var schema = await SchemaExtractor(DatabaseIO(connection)).schema();
  var code = DartGenerator();
  var schemaFile = 'example_database_schema.dart';
  File('example/$schemaFile')
      .writeAsStringSync(await code.generateEntities(schema.tables));

  File('example/example_database_crud.dart').writeAsStringSync(
      await code.generateCrudFile(schema.tables, imports: [schemaFile]));
}

class StdoutLog extends Log {
  @override
  void warning(String message) => print(message);

  @override
  void severe(String message) => print(message);
}
