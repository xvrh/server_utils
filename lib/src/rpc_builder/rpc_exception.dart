import 'package:json_annotation/json_annotation.dart';

part 'rpc_exception.g.dart';

@JsonSerializable()
class RpcException implements Exception {
  final String url, controller, method;
  final RpcInternalError? internalError;
  final RpcArgumentError? argumentError;

  RpcException(
      {required this.url,
      required this.controller,
      required this.method,
      this.internalError,
      this.argumentError});

  static RpcException fromJson(Map<String, dynamic> json) =>
      _$RpcExceptionFromJson(json);

  factory RpcException.internalError(error, StackTrace stackTrace,
      {required String url,
      required String controller,
      required String method}) {
    return RpcException(
        url: url,
        controller: controller,
        method: method,
        internalError: RpcInternalError.fromError(error, stackTrace));
  }

  Map<String, dynamic> toJson() => _$RpcExceptionToJson(this);

  @override
  String toString() {
    if (internalError != null) {
      return 'Internal server error on $controller/$method: $internalError';
    } else {
      assert(argumentError != null);
      return 'Argument error: on $controller/$method: $argumentError';
    }
  }
}

@JsonSerializable()
class RpcInternalError implements Exception {
  final String error;
  final String? stackTrace;
  final String exceptionType;

  RpcInternalError(
      {required this.error,
      required this.stackTrace,
      required this.exceptionType});

  static RpcInternalError fromJson(Map<String, dynamic> json) =>
      _$RpcInternalErrorFromJson(json);

  factory RpcInternalError.fromError(
    error,
    StackTrace? stackTrace,
  ) {
    return RpcInternalError(
        error: error.toString(),
        stackTrace: stackTrace?.toString(),
        exceptionType: error.runtimeType.toString());
  }

  Map<String, dynamic> toJson() => _$RpcInternalErrorToJson(this);

  @override
  String toString() => '$error\n$stackTrace';
}

@JsonSerializable()
class RpcArgumentError implements Exception {
  final String message;
  final String field;
  final String? rawValue;

  RpcArgumentError(
      {required this.message, required this.field, required this.rawValue});

  static RpcArgumentError fromJson(Map<String, dynamic> json) =>
      _$RpcArgumentErrorFromJson(json);

  Map<String, dynamic> toJson() => _$RpcArgumentErrorToJson(this);

  @override
  String toString() => '$field invalid ($rawValue): $message';
}
