// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exceptions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcException _$RpcExceptionFromJson(Map<String, dynamic> json) {
  return RpcException(
    json['status'] as int,
    json['message'] as String,
    data: json['data'] as Map<String, dynamic>?,
  );
}

Map<String, dynamic> _$RpcExceptionToJson(RpcException instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

NotFoundException _$NotFoundExceptionFromJson(Map<String, dynamic> json) {
  return NotFoundException(
    json['message'] as String,
  );
}

Map<String, dynamic> _$NotFoundExceptionToJson(NotFoundException instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

InvalidInputException _$InvalidInputExceptionFromJson(
    Map<String, dynamic> json) {
  return InvalidInputException(
    json['message'] as String,
  );
}

Map<String, dynamic> _$InvalidInputExceptionToJson(
        InvalidInputException instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
