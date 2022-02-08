import 'dart:developer' as dev;
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart';
import 'package:server_utils/database_builder.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';
import 'example_database.dart';

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
        'You need to pass `dart --enable-vm-service --disable-service-auth-codes'
        ' ${p.relative(Platform.script.toFilePath())}` to enable hot reload');
  }

  await runDatabaseBuilder(
    exampleDatabaseServer,
    exampleDatabaseName,
    migrations: ['example/test_database'],
    queries: [
      'example/**.queries.sql',
      'lib/**.queries.sql',
    ],
    afterCreate: _afterCreate,
    afterRefresh: _afterRefresh,
  );
}

Future<void> _afterReload() async {
  Logger.root.level = Level.ALL;
}

Future<void> _afterCreate(PostgreSQLConnection connection) async {}

Future<void> _afterRefresh(PostgreSQLConnection connection) async {
  var database = DatabaseIO(connection);
  var schema = await SchemaExtractor(database).schema();
  var enumExtractor = EnumExtractor(database, schema);
  var code = DartGenerator(
    tables: schema.withConfig({}),
    enums: [
      await enumExtractor.extractTable('app_role'),
    ],
  );
  var schemaFile = 'example_database_schema.dart';
  File('example/$schemaFile').writeAsStringSync(await code.generateEntities());

  File('example/example_database_crud.dart')
      .writeAsStringSync(await code.generateCrudFile(imports: [schemaFile]));
}

class StdoutLog extends Log {
  @override
  void warning(String message) => print(message);

  @override
  void severe(String message) => print(message);
}
