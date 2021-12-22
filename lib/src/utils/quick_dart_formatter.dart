import 'dart:convert';
import 'dart:io';
import 'package:process_runner/process_runner.dart';

Future<String> formatDartCode(String rawCode) async {
  var result = await ProcessRunner().runProcess(
      [Platform.executable, 'format', '--stdin-name', 'file.dart'],
      stdin: Stream.value(utf8.encode(rawCode)));
  return result.output;
}
