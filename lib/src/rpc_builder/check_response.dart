import 'dart:convert';
import 'package:http/http.dart';
import '../../rpc_client.dart';

void checkResponseSuccess(Uri url, Response response) {
  if (response.statusCode < 400) return;

  RpcException? rpcException;
  if (response.statusCode == 400 || response.statusCode == 500) {
    try {
      rpcException = RpcException.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (_) {
      // On essaye de désérializer le body, si on n'y arrive pas c'est que c'est
      // une erreur à autre niveau de la stack
    }
  }
  if (rpcException != null) throw rpcException;

  var message = 'Request to $url failed with status ${response.statusCode}';
  if (response.reasonPhrase != null) {
    message = '$message: ${response.reasonPhrase}';
  }
  throw ClientException('$message.', url);
}
