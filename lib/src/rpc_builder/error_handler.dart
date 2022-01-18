import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'annotations.dart';
import 'exception_wrapper.dart';
import 'exceptions.dart';

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
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
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
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
}

Handler globalRpcErrorMiddleware(Handler innerHandler) {
  return (request) async {
    try {
      var response = await innerHandler(request);
      if (response == Router.routeNotFound) {
        throw Exception('Route not found');
      }
      return response;
    } catch (e, s) {
      return Response.internalServerError(
        body: jsonEncode(
          RpcExceptionWrapper(
            api: '',
            url: request.requestedUri.toString(),
            stackTrace: '$s',
            method: request.method,
            message: '$e',
          ),
        ),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      );
    }
  };
}
