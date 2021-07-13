import 'package:json_annotation/json_annotation.dart';

part 'exception_wrapper.g.dart';

@JsonSerializable()
class RpcExceptionWrapper {
  final String url, api, method;
  final String? rpcExceptionType;
  final Map<String, Object?>? rpcExceptionJson;
  final String message;
  final String stackTrace;

  RpcExceptionWrapper({
    required this.url,
    required this.api,
    required this.method,
    this.rpcExceptionType,
    this.rpcExceptionJson,
    required this.message,
    required this.stackTrace,
  });

  static RpcExceptionWrapper fromJson(Map<String, dynamic> json) =>
      _$RpcExceptionWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$RpcExceptionWrapperToJson(this);
}
