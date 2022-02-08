// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exceptions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcException _$RpcExceptionFromJson(Map<String, dynamic> json) => RpcException(
      json['status'] as int,
      json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RpcExceptionToJson(RpcException instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

NotFoundRpcException _$NotFoundRpcExceptionFromJson(
        Map<String, dynamic> json) =>
    NotFoundRpcException(
      json['message'] as String,
    );

Map<String, dynamic> _$NotFoundRpcExceptionToJson(
        NotFoundRpcException instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

InvalidInputRpcException _$InvalidInputRpcExceptionFromJson(
        Map<String, dynamic> json) =>
    InvalidInputRpcException(
      json['message'] as String,
    );

Map<String, dynamic> _$InvalidInputRpcExceptionToJson(
        InvalidInputRpcException instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
