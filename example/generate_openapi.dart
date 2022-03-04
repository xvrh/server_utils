import 'dart:io';
import 'package:server_utils/rpc_openapi.dart';

void main() async {
  var result = await generateOpenApiSchema(
    [
      Api('example/api.dart', description: ''),
    ],
    title: 'API',
    description: 'API',
    version: '0.0.1',
  );
  File('example/api.openapi.json').writeAsStringSync(result);
}
