import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'rpc_exception.dart';

Response rpcErrorHandler(error, StackTrace stackTrace) {
  if (error is RpcArgumentError) {
    return Response(HttpStatus.badRequest,
        body: jsonEncode(RpcException(
            url: '', controller: '', method: '', argumentError: error)));
  } else {
    return Response.internalServerError(
        body: jsonEncode(RpcException.internalError(
      error,
      stackTrace,
      controller: '',
      url: '',
      method: '',
    )));
  }
}
