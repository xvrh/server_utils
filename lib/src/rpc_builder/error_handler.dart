import 'dart:convert';
import 'package:server_utils/src/rpc_builder/exception_wrapper.dart';
import 'package:shelf/shelf.dart';
import 'annotations.dart';
import 'exceptions.dart';
import 'exception_wrapper.dart';

Response rpcErrorHandler(
    Api api, Request request, exception, StackTrace stackTrace) {
  if (exception is RpcException) {
    return Response(
      exception.status,
      body: jsonEncode(
        RpcExceptionWrapper(
          api: api.name,
          url: request.requestedUri.toString(),
          stackTrace: '$stackTrace',
          method: request.method,
          rpcExceptionType: RpcException.nameFor(exception),
          rpcExceptionJson: exception.toJson(),
          message: '$exception',
        ),
      ),
    );
  } else {
    return Response.internalServerError(
      body: jsonEncode(
        RpcExceptionWrapper(
          api: api.name,
          url: request.requestedUri.toString(),
          stackTrace: '$stackTrace',
          method: request.method,
          message: '$exception',
        ),
      ),
    );
  }
}
