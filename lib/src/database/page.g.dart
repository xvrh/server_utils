// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Page<TEntities> _$PageFromJson<TEntities>(Map<String, dynamic> json) {
  return Page<TEntities>(
    totalLength: json['totalLength'] as int,
    pageRequest: json['pageRequest'] == null
        ? null
        : PageRequest.fromJson(json['pageRequest'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PageToJson<TEntities>(Page<TEntities> instance) =>
    <String, dynamic>{
      'totalLength': instance.totalLength,
      'pageRequest': instance.pageRequest,
    };

PageRequest _$PageRequestFromJson(Map<String, dynamic> json) {
  return PageRequest(
    pageIndex: json['pageIndex'] as int,
    pageSize: json['pageSize'] as int,
    sort: json['sort'] == null
        ? null
        : Sort.fromJson(json['sort'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PageRequestToJson(PageRequest instance) =>
    <String, dynamic>{
      'pageSize': instance.pageSize,
      'pageIndex': instance.pageIndex,
      'sort': instance.sort,
    };

Sort _$SortFromJson(Map<String, dynamic> json) {
  return Sort(
    json['field'] as String,
    direction: _$enumDecodeNullable(_$SortDirectionEnumMap, json['direction']),
  );
}

Map<String, dynamic> _$SortToJson(Sort instance) => <String, dynamic>{
      'field': instance.field,
      'direction': _$SortDirectionEnumMap[instance.direction],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$SortDirectionEnumMap = {
  SortDirection.asc: 'asc',
  SortDirection.desc: 'desc',
};
