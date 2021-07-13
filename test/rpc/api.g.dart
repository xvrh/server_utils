// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) {
  return News(
    json['id'] as int,
    title: json['title'] as String?,
  )
    ..body = json['body'] as String?
    ..author = json['author'] as String?
    ..moveType = _$enumDecodeNullable(_$MoveTypeEnumMap, json['moveType']);
}

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'author': instance.author,
      'moveType': _$MoveTypeEnumMap[instance.moveType],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$MoveTypeEnumMap = {
  MoveType.inside: 'inside',
  MoveType.after: 'after',
  MoveType.before: 'before',
};

Page<TContent> _$PageFromJson<TContent>(Map<String, dynamic> json) {
  return Page<TContent>(
    json['size'] as int,
  );
}

Map<String, dynamic> _$PageToJson<TContent>(Page<TContent> instance) =>
    <String, dynamic>{
      'size': instance.size,
    };

// **************************************************************************
// RpcRouterGenerator
// **************************************************************************

final $newsApi = Api<NewsApi>.info(
    path: '/news/', name: 'NewsApi', factory: _$NewsApiHandler);

Handler _$NewsApiHandler(NewsApi api) {
  var router = createRpcRouter($newsApi);

  router.get('simpleString', (request) async {
    var result = await api.simpleString();
    return result;
  });

  router.get('greeting', (request) async {
    var result = await api.greeting(
      request.queryParameter('name').requiredString(),
    );
    return result;
  });

  router.get('greetingWithNamed', (request) async {
    var result = await api.greetingWithNamed(
      request.queryParameter('name').requiredString(),
      prefix: request.queryParameter('prefix').nullableString(),
      suffix: request.queryParameter('suffix').nullableString(),
    );
    return result;
  });

  router.get('greetingWithRequired', (request) async {
    var result = await api.greetingWithRequired(
      count: request.queryParameter('count').requiredInt(),
    );
    return result;
  });

  router.get('allTypes', (request) async {
    var result = await api.allTypes(
      aInt: request.queryParameter('aInt').nullableInt(),
      requiredInt: request.queryParameter('requiredInt').requiredInt(),
      aBool: request.queryParameter('aBool').nullableBool(),
      requiredBool: request.queryParameter('requiredBool').requiredBool(),
      aNum: request.queryParameter('aNum').nullableNum(),
      requiredNum: request.queryParameter('requiredNum').requiredNum(),
      aDouble: request.queryParameter('aDouble').nullableDouble(),
      requiredDouble: request.queryParameter('requiredDouble').requiredDouble(),
      aString: request.queryParameter('aString').nullableString(),
      requiredString: request.queryParameter('requiredString').requiredString(),
      aDate: request.queryParameter('aDate').nullableDateTime(),
      requiredDate: request.queryParameter('requiredDate').requiredDateTime(),
    );
    return result;
  });

  router.get('getList', (request) async {
    var result = await api.getList(
      (request.queryParameter('ints').requiredJson as List<Object?>)
          .map((i) => (i! as num).toInt())
          .toList(),
      (request.queryParameter('bools').requiredJson as List<Object?>)
          .map((i) => i! as bool)
          .toList(),
      (request.queryParameter('strings').requiredJson as List<Object?>)
          .map((i) => i! as String)
          .toList(),
    );
    return result;
  });

  router.get('getListNullableValue', (request) async {
    var result = await api.getListNullableValue(
      (request.queryParameter('ints').requiredJson as List<Object?>)
          .map((i) => (i as num?)?.toInt())
          .toList(),
      (request.queryParameter('bools').requiredJson as List<Object?>)
          .map((i) => i as bool?)
          .toList(),
      (request.queryParameter('strings').requiredJson as List<Object?>)
          .map((i) => i as String?)
          .toList(),
    );
    return result;
  });

  router.get('getListNullable', (request) async {
    var result = await api.getListNullable(
      (request.queryParameter('ints').nullableJson as List<Object?>?)
          ?.map((i) => (i as num?)?.toInt())
          .toList(),
      (request.queryParameter('bools').nullableJson as List<Object?>?)
          ?.map((i) => i as bool?)
          .toList(),
      (request.queryParameter('strings').nullableJson as List<Object?>?)
          ?.map((i) => i as String?)
          .toList(),
    );
    return result;
  });

  router.get('getMap', (request) async {
    var result = await api.getMap(
      (request.queryParameter('ints').requiredJson as Map<String, Object?>)
          .map((k, v) => MapEntry(k, (v! as num).toInt())),
      (request.queryParameter('bools').requiredJson as Map<String, Object?>)
          .map((k, v) => MapEntry(k, v! as bool)),
      (request.queryParameter('strings').requiredJson as Map<String, Object?>)
          .map((k, v) => MapEntry(k, v! as String)),
    );
    return result;
  });

  router.post('postList', (request) async {
    var body = await request.body;
    var result = await api.postList(
      (body['ints']! as List<Object?>).map((i) => (i! as num).toInt()).toList(),
      (body['bools']! as List<Object?>).map((i) => i! as bool).toList(),
      (body['strings']! as List<Object?>).map((i) => i! as String).toList(),
    );
    return result;
  });

  router.post('postMap', (request) async {
    var body = await request.body;
    var result = await api.postMap(
      (body['ints']! as Map<String, Object?>)
          .map((k, v) => MapEntry(k, (v! as num).toInt())),
      (body['bools']! as Map<String, Object?>)
          .map((k, v) => MapEntry(k, v! as bool)),
      (body['strings']! as Map<String, Object?>)
          .map((k, v) => MapEntry(k, v! as String)),
    );
    return result;
  });

  router.get('lastNews', (request) async {
    var result = await api.lastNews(
      count: request.queryParameter('count').nullableInt(),
    );
    return result.map((i) => i.toJson()).toList();
  });

  router.post('echo', (request) async {
    var body = await request.body;
    var result = await api.echo(
      News.fromJson(body['news']! as Map<String, Object?>),
    );
    return result.toJson();
  });

  router.post('sendReceiveNewsPost', (request) async {
    var body = await request.body;
    var result = await api.sendReceiveNewsPost(
      (body['news']! as List<Object?>)
          .map((i) => News.fromJson(i! as Map<String, Object?>))
          .toList(),
    );
    return result.map((i) => i.toJson()).toList();
  });

  router.get('sendReceiveNewsGet', (request) async {
    var result = await api.sendReceiveNewsGet(
      (request.queryParameter('news').requiredJson as List<Object?>)
          .map((i) => News.fromJson(i! as Map<String, Object?>))
          .toList(),
    );
    return result.map((i) => i.toJson()).toList();
  });

  router.post('sendReceiveMapNewsPost', (request) async {
    var body = await request.body;
    var result = await api.sendReceiveMapNewsPost(
      (body['news']! as Map<String, Object?>).map(
          (k, v) => MapEntry(k, News.fromJson(v! as Map<String, Object?>))),
    );
    return result.map((k, v) => MapEntry(k, v.toJson()));
  });

  router.get('sendReceiveMapNewsGet', (request) async {
    var result = await api.sendReceiveMapNewsGet(
      (request.queryParameter('news').requiredJson as Map<String, Object?>).map(
          (k, v) => MapEntry(k, News.fromJson(v! as Map<String, Object?>))),
    );
    return result.map((k, v) => MapEntry(k, v.toJson()));
  });

  router.get('getListString', (request) async {
    var result = await api.getListString();
    return result;
  });

  router.post('getListStringPost', (request) async {
    var result = await api.getListStringPost();
    return result;
  });

  router.get('getListBool', (request) {
    var result = api.getListBool();
    return result;
  });

  router.post('getListBoolPost', (request) {
    var result = api.getListBoolPost();
    return result;
  });

  router.post('aVoid', (request) async {
    var body = await request.body;
    api.aVoid(
      (body['id']! as num).toInt(),
    );
  });

  router.get('returnBool', (request) {
    var result = api.returnBool();
    return result;
  });

  router.get('returnNum', (request) {
    var result = api.returnNum();
    return result;
  });

  router.get('returnDouble', (request) {
    var result = api.returnDouble();
    return result;
  });

  router.get('returnInt', (request) {
    var result = api.returnInt();
    return result;
  });

  router.get('returnDateTime', (request) {
    var result = api.returnDateTime();
    return result.toIso8601String();
  });

  router.get('returnListDateTime', (request) {
    var result = api.returnListDateTime();
    return result.map((i) => i.toIso8601String()).toList();
  });

  router.get('returnFutureListDateTime', (request) async {
    var result = await api.returnFutureListDateTime();
    return result.map((i) => i.toIso8601String()).toList();
  });

  router.get('echoEnum', (request) {
    var result = api.echoEnum(
      request.queryParameter('type1').requiredEnum(MoveType.values),
      type2: request.queryParameter('type2').nullableEnum(MoveType?.values),
    );
    return result.map((i) => apiUtils.enumName(i)).toList();
  });

  router.get('getPage', (request) {
    var result = api.getPage();
    return result.toJson();
  });

  router.get('getPagesMap', (request) {
    var result = api.getPagesMap();
    return result.map((k, v) => MapEntry(k, v.toJson()));
  });

  router.get('getPagesList', (request) {
    var result = api.getPagesList();
    return result.map((i) => i.toJson()).toList();
  });

  router.get('throwAnException', (request) {
    api.throwAnException();
  });

  router.post('throwANotFoundException', (request) {
    api.throwANotFoundException();
  });

  router.post('throwAInvalidInputException', (request) {
    api.throwAInvalidInputException();
  });

  router.post('throwOtherException', (request) async {
    var body = await request.body;
    api.throwOtherException(
      d1: (body['d1']! as num).toInt(),
    );
  });

  router.get('echoList', (request) {
    var result = api.echoList(
      (request.queryParameter('list').requiredJson as List<Object?>)
          .map((i) => (i as num?)?.toInt())
          .toList(),
    );
    return result;
  });

  router.get('echoMap', (request) {
    var result = api.echoMap(
      (request.queryParameter('map').requiredJson as Map<String, Object?>)
          .map((k, v) => MapEntry(k, (v as num?)?.toInt())),
    );
    return result;
  });

  router.get('echoListNullable', (request) {
    var result = api.echoListNullable(
      (request.queryParameter('list').nullableJson as List<Object?>?)
          ?.map((i) => (i as num?)?.toInt())
          .toList(),
    );
    return result;
  });

  router.get('echoMapNullable', (request) {
    var result = api.echoMapNullable(
      (request.queryParameter('map').nullableJson as Map<String, Object?>?)
          ?.map((k, v) => MapEntry(k, (v as num?)?.toInt())),
    );
    return result;
  });

  return router.handler;
}
