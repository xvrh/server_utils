import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';

Future<List<Script>> scriptsFromPaths(List<String> paths) async {
  var results = <Script>[];
  for (var path in paths) {
    var uri = Uri.parse(path);
    if (uri.scheme == 'package') {
      uri = (await Isolate.resolvePackageUri(uri))!;
    }

    var filePath = uri.toFilePath();
    var fileType = FileSystemEntity.typeSync(filePath);
    if (fileType == FileSystemEntityType.file) {
      // We don't check the extension because the file is added explicitly.
      results.add(Script(File(filePath)));
    } else if (fileType == FileSystemEntityType.directory) {
      var directory = Directory(uri.toFilePath());
      results.addAll(directory
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => const ['.sql', '.dart']
              .contains(p.extension(f.path.toLowerCase())))
          .map((f) => Script(f)));
    }
  }

  mergeSort<Script>(results, compare: (a, b) => compareNatural(a.name, b.name));

  return results;
}

class Script {
  final File file;
  final ScriptType type;
  final String name;

  Script(this.file)
      : type = p.extension(file.path) == '.dart'
            ? ScriptType.dart
            : ScriptType.sql,
        name = p.basenameWithoutExtension(file.path);
}

enum ScriptType { sql, dart }
