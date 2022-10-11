import 'package:dart_style/dart_style.dart';

final _formatter = DartFormatter();

Future<String> formatDartCode(String rawCode) async {
  try {
    return _formatter.format(rawCode);
  } catch (e) {
    print('Failed to format $rawCode');
  }
  return rawCode;
}
