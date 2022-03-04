// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entity _$EntityFromJson(Map<String, dynamic> json) => Entity(
      myEnum: $enumDecode(_$OneEnumEnumMap, json['myEnum']),
      otherProp: json['otherProp'] as num,
    );

Map<String, dynamic> _$EntityToJson(Entity instance) => <String, dynamic>{
      'myEnum': _$OneEnumEnumMap[instance.myEnum],
      'otherProp': instance.otherProp,
    };

const _$OneEnumEnumMap = {
  OneEnum.value1: 'value1',
  OneEnum.value2: 'value2',
};

// **************************************************************************
// RpcRouterGenerator
// **************************************************************************

const $pageApi = Api<PageApi>.info(
    path: '/page/', name: 'PageApi', factory: _$PageApiHandler);

Handler _$PageApiHandler(PageApi api) {
  var router = createRpcRouter($pageApi);

  router.get('fetch-entity', (request) async {
    var result = await api.fetchEntity();
    return result.toJson();
  });

  return router.handler;
}
