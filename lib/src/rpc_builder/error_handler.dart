import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'annotations.dart';
import 'exception_wrapper.dart';
import 'exceptions.dart';

final _logger = Logger('rpc');

Response rpcErrorHandler(
    Api api, Request request, exception, StackTrace stackTrace) {
  _logger.info(
      'Api error ${request.requestedUri}: $exception', exception, stackTrace);
  return _exceptionToResponse(request, exception, stackTrace, api: api);
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
      _logger.info('Api error ${request.requestedUri}: $e', e, s);
      return _exceptionToResponse(request, e, s, api: null);
    }
  };
}

Response _exceptionToResponse(
    Request request, dynamic exception, StackTrace stackTrace,
    {required Api? api}) {
  if (exception is RpcException) {
    return Response(
      exception.status,
      body: jsonEncode(
        RpcExceptionWrapper(
          api: api?.name ?? '',
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
          api: api?.name ?? '',
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
