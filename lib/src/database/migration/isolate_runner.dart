import 'dart:async';
import 'dart:isolate';
import 'migration_client.dart';

class IsolateRunner {
  final Isolate isolate;
  final SendPort _sendPort;
  final Stream _receiveStream;
  final _onExitCompleter = Completer();
  final _onExitPort = ReceivePort();
  final ReceivePort _mainPort;

  IsolateRunner._(
      this.isolate, this._sendPort, this._receiveStream, this._mainPort) {
    isolate.addOnExitListener(_onExitPort.sendPort);
    _onExitPort.first.then(_onExitCompleter.complete);
  }

  static Future<IsolateRunner> start(List<String> allFiles,
      {required String method,
      required MigrationContextCode migrationContext}) async {
    var mainPort = ReceivePort();

    var allImports = <String, String>{};
    var importBuffers = StringBuffer();
    var methodMap = StringBuffer();
    var index = 0;
    for (var file in allFiles) {
      allImports['i$index'] = file;
      importBuffers.writeln("import '${Uri.file(file)}' as i$index;");
      methodMap.writeln("  '$file' : i$index.$method,");
      ++index;
    }

    var isolateSource = '''
import 'dart:isolate';
import 'package:server_utils/migration.dart' show MigrationContext;
${migrationContext.import}
$importBuffers

final methods = <String, Function(MigrationContext)>{
$methodMap
};

void main(args, Map message) async {
  var port = message['port']! as SendPort;
  var receivePort = ReceivePort();
  port.send(receivePort.sendPort);
  
  var migrationContext = ${migrationContext.creationCode};
  try {
    await for (var message in receivePort) {
      var file = message['file']!;
      var callback = methods[file]!;
      await callback(migrationContext);
      port.send('ok');
    }
  } finally {
    await migrationContext.close();
    receivePort.close();
  }
}   
''';

    var isolate = await Isolate.spawnUri(
        Uri.dataFromString(isolateSource, mimeType: 'application/dart'), [], {
      'port': mainPort.sendPort,
    });

    var receiveStream = mainPort.asBroadcastStream();
    var response = await receiveStream.first as SendPort;

    return IsolateRunner._(isolate, response, receiveStream, mainPort);
  }

  Future<void> callMigrateMethod(String file) async {
    _sendPort.send({'file': file});
    await _receiveStream.first;
  }

  Future<void> stop() {
    isolate.kill();
    _mainPort.close();

    return _onExitCompleter.future;
  }
}
