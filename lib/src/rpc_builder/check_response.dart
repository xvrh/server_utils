import 'dart:convert';
import 'package:http/http.dart';
import '../../rpc_client.dart';
import 'exception_wrapper.dart';

void checkResponseSuccess(Uri url, Response response) {
  if (response.statusCode < 400) return;

  RpcExceptionWrapper rpcException;
  try {
    rpcException = RpcExceptionWrapper.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } catch (_) {
    // deserialization failed, this is not an encoded RpcException
    var message =
        'Request to [${response.request?.method}] $url failed with status ${response.statusCode}';
    if (response.reasonPhrase != null) {
      message = '$message: ${response.reasonPhrase}';
    }
    var body = response.body;
    if (body.isNotEmpty) {
      message += '\n$body';
    }
    throw ClientException('$message.', url);
  }

  var innerJson = rpcException.rpcExceptionJson;
  if (innerJson != null) {
    var exception =
        RpcException.deserialize(rpcException.rpcExceptionType, innerJson);
    throw exception;
  } else {
    Error.throwWithStackTrace(InternalServerException(rpcException),
        StackTrace.fromString(rpcException.stackTrace));
  }
}

class InternalServerException implements Exception {
  final RpcExceptionWrapper exception;

  InternalServerException(this.exception);

  @override
  String toString() => exception.message;
}
