// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exception_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcExceptionWrapper _$RpcExceptionWrapperFromJson(Map<String, dynamic> json) {
  return RpcExceptionWrapper(
    url: json['url'] as String,
    api: json['api'] as String,
    method: json['method'] as String,
    rpcExceptionType: json['rpcExceptionType'] as String?,
    rpcExceptionJson: json['rpcExceptionJson'] as Map<String, dynamic>?,
    message: json['message'] as String,
    stackTrace: json['stackTrace'] as String,
  );
}

Map<String, dynamic> _$RpcExceptionWrapperToJson(
        RpcExceptionWrapper instance) =>
    <String, dynamic>{
      'url': instance.url,
      'api': instance.api,
      'method': instance.method,
      'rpcExceptionType': instance.rpcExceptionType,
      'rpcExceptionJson': instance.rpcExceptionJson,
      'message': instance.message,
      'stackTrace': instance.stackTrace,
    };
