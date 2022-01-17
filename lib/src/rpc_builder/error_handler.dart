import 'dart:convert';
import 'package:shelf/shelf.dart';
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

/*
final Middleware globalRpcErrorMiddleware =
    createMiddleware(errorHandler: (e, s) async {
  return Response.internalServerError(
    body: jsonEncode(
      RpcExceptionWrapper(
        api: '',
        url: '',
        stackTrace: '$s',
        method: '',
        message: '$e',
      ),
    ),
  );
});*/

Handler globalRpcErrorMiddleware(Handler innerHandler) {
  return (request) async {
    try {
      return await innerHandler(request);
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
      );
    }
  };
}

/*
    return (request) async {
      try {
        var response = await callback(_RequestWrapper(request));

        return Response.ok(jsonEncode(response),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'});
      } catch (e, stackTrace) {
        return rpcErrorHandler(apiInfo, request, e, stackTrace);
      }
    };
 */
