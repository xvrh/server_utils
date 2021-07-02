// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpc_exception.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcException _$RpcExceptionFromJson(Map<String, dynamic> json) {
  return RpcException(
    url: json['url'] as String,
    controller: json['controller'] as String,
    method: json['method'] as String,
    internalError: json['internalError'] == null
        ? null
        : RpcInternalError.fromJson(
            json['internalError'] as Map<String, dynamic>),
    argumentError: json['argumentError'] == null
        ? null
        : RpcArgumentError.fromJson(
            json['argumentError'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RpcExceptionToJson(RpcException instance) =>
    <String, dynamic>{
      'url': instance.url,
      'controller': instance.controller,
      'method': instance.method,
      'internalError': instance.internalError,
      'argumentError': instance.argumentError,
    };

RpcInternalError _$RpcInternalErrorFromJson(Map<String, dynamic> json) {
  return RpcInternalError(
    error: json['error'] as String,
    stackTrace: json['stackTrace'] as String?,
    exceptionType: json['exceptionType'] as String,
  );
}

Map<String, dynamic> _$RpcInternalErrorToJson(RpcInternalError instance) =>
    <String, dynamic>{
      'error': instance.error,
      'stackTrace': instance.stackTrace,
      'exceptionType': instance.exceptionType,
    };

RpcArgumentError _$RpcArgumentErrorFromJson(Map<String, dynamic> json) {
  return RpcArgumentError(
    message: json['message'] as String,
    field: json['field'] as String,
    rawValue: json['rawValue'] as String?,
  );
}

Map<String, dynamic> _$RpcArgumentErrorToJson(RpcArgumentError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'field': instance.field,
      'rawValue': instance.rawValue,
    };
