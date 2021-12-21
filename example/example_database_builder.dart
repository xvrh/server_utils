import 'dart:developer' as dev;
import 'dart:io';
import 'package:server_utils/src/database/generate_script.dart';
import 'package:server_utils/src/test_database.dart';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';
import 'package:stream_transform/stream_transform.dart';

void main() async {
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

      print('Hot reloaded ${DateTime.now()}');
    });
  } else {
    print(
        'You need to pass `--enable-vm-service --disable-service-auth-codes` to enable hot reload');
  }

  /// Run an empty database to generate the queries to introspect postgres
  /// database
  await runDatabaseBuilder(
    testDatabase,
    'example_database',
    migrations: {'example/test_database'},
    queries: {'example/**.queries.sql'},
  );
}

class StdoutLog extends Log {
  @override
  void warning(String message) => print(message);

  @override
  void severe(String message) => print(message);
}
