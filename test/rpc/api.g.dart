// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) => News(
      json['id'] as int,
      title: json['title'] as String?,
    )
      ..body = json['body'] as String?
      ..author = json['author'] as String?
      ..moveType = $enumDecodeNullable(_$MoveTypeEnumMap, json['moveType']);

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'author': instance.author,
      'moveType': _$MoveTypeEnumMap[instance.moveType],
    };

const _$MoveTypeEnumMap = {
  MoveType.inside: 'inside',
  MoveType.after: 'after',
  MoveType.before: 'before',
};

CmsPage<TContent> _$CmsPageFromJson<TContent>(Map<String, dynamic> json) =>
    CmsPage<TContent>(
      json['size'] as int,
    );

Map<String, dynamic> _$CmsPageToJson<TContent>(CmsPage<TContent> instance) =>
    <String, dynamic>{
      'size': instance.size,
    };

// **************************************************************************
// RpcRouterGenerator
// **************************************************************************

const $newsApi = Api<NewsApi>.info(
    path: '/news', name: 'NewsApi', factory: _$NewsApiHandler);

Handler _$NewsApiHandler(NewsApi api) {
  var router = createRpcRouter($newsApi);

  router.get('simple-string', (request) async {
    var result = await api.simpleString();
    return result;
  });

  router.get('greeting', (request) async {
    var result = await api.greeting(
      request.queryParameter('name').requiredString(),
    );
    return result;
  });

  router.get('greeting-with-named', (request) async {
    var result = await api.greetingWithNamed(
      request.queryParameter('name').requiredString(),
      prefix: request.queryParameter('prefix').nullableString(),
      suffix: request.queryParameter('suffix').nullableString(),
    );
    return result;
  });

  router.get('greeting-with-required', (request) async {
    var result = await api.greetingWithRequired(
      count: request.queryParameter('count').requiredInt(),
    );
    return result;
  });

  router.get('all-types', (request) async {
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

  router.get('get-list', (request) async {
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

  router.get('get-list-nullable-value', (request) async {
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

  router.get('get-list-nullable', (request) async {
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

  router.get('get-map', (request) async {
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

  router.post('post-list', (request) async {
    var body = await request.body;
    var result = await api.postList(
      (body['ints']! as List<Object?>).map((i) => (i! as num).toInt()).toList(),
      (body['bools']! as List<Object?>).map((i) => i! as bool).toList(),
      (body['strings']! as List<Object?>).map((i) => i! as String).toList(),
    );
    return result;
  });

  router.post('post-map', (request) async {
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

  router.get('last-news', (request) async {
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

  router.post('send-receive-news-post', (request) async {
    var body = await request.body;
    var result = await api.sendReceiveNewsPost(
      (body['news']! as List<Object?>)
          .map((i) => News.fromJson(i! as Map<String, Object?>))
          .toList(),
    );
    return result.map((i) => i.toJson()).toList();
  });

  router.get('send-receive-news-get', (request) async {
    var result = await api.sendReceiveNewsGet(
      (request.queryParameter('news').requiredJson as List<Object?>)
          .map((i) => News.fromJson(i! as Map<String, Object?>))
          .toList(),
    );
    return result.map((i) => i.toJson()).toList();
  });

  router.post('send-receive-map-news-post', (request) async {
    var body = await request.body;
    var result = await api.sendReceiveMapNewsPost(
      (body['news']! as Map<String, Object?>).map(
          (k, v) => MapEntry(k, News.fromJson(v! as Map<String, Object?>))),
    );
    return result.map((k, v) => MapEntry(k, v.toJson()));
  });

  router.get('send-receive-map-news-get', (request) async {
    var result = await api.sendReceiveMapNewsGet(
      (request.queryParameter('news').requiredJson as Map<String, Object?>).map(
          (k, v) => MapEntry(k, News.fromJson(v! as Map<String, Object?>))),
    );
    return result.map((k, v) => MapEntry(k, v.toJson()));
  });

  router.get('get-list-string', (request) async {
    var result = await api.getListString();
    return result;
  });

  router.post('get-list-string-post', (request) async {
    var result = await api.getListStringPost();
    return result;
  });

  router.get('get-list-bool', (request) {
    var result = api.getListBool();
    return result;
  });

  router.post('get-list-bool-post', (request) {
    var result = api.getListBoolPost();
    return result;
  });

  router.post('a-void', (request) async {
    var body = await request.body;
    api.aVoid(
      (body['id']! as num).toInt(),
    );
  });

  router.get('return-bool', (request) {
    var result = api.returnBool();
    return result;
  });

  router.get('return-num', (request) {
    var result = api.returnNum();
    return result;
  });

  router.get('return-double', (request) {
    var result = api.returnDouble();
    return result;
  });

  router.get('return-int', (request) {
    var result = api.returnInt();
    return result;
  });

  router.get('return-date-time', (request) {
    var result = api.returnDateTime();
    return result.toIso8601String();
  });

  router.get('return-list-date-time', (request) {
    var result = api.returnListDateTime();
    return result.map((i) => i.toIso8601String()).toList();
  });

  router.get('return-future-list-date-time', (request) async {
    var result = await api.returnFutureListDateTime();
    return result.map((i) => i.toIso8601String()).toList();
  });

  router.get('echo-enum', (request) {
    var result = api.echoEnum(
      request.queryParameter('type1').requiredEnum(MoveType.values),
      type2: request.queryParameter('type2').nullableEnum(MoveType?.values),
    );
    return result.map((i) => apiUtils.enumName(i)).toList();
  });

  router.get('get-page', (request) {
    var result = api.getPage();
    return result.toJson();
  });

  router.get('get-pages-map', (request) {
    var result = api.getPagesMap();
    return result.map((k, v) => MapEntry(k, v.toJson()));
  });

  router.get('get-pages-list', (request) {
    var result = api.getPagesList();
    return result.map((i) => i.toJson()).toList();
  });

  router.get('throw-an-exception', (request) {
    api.throwAnException();
  });

  router.post('throwa-not-found-exception', (request) {
    api.throwANotFoundException();
  });

  router.post('throwa-invalid-input-exception', (request) {
    api.throwAInvalidInputException();
  });

  router.post('throw-other-exception', (request) async {
    var body = await request.body;
    api.throwOtherException(
      d1: (body['d1']! as num).toInt(),
    );
  });

  router.get('echo-list', (request) {
    var result = api.echoList(
      (request.queryParameter('list').requiredJson as List<Object?>)
          .map((i) => (i as num?)?.toInt())
          .toList(),
    );
    return result;
  });

  router.get('echo-map', (request) {
    var result = api.echoMap(
      (request.queryParameter('map').requiredJson as Map<String, Object?>)
          .map((k, v) => MapEntry(k, (v as num?)?.toInt())),
    );
    return result;
  });

  router.get('echo-list-nullable', (request) {
    var result = api.echoListNullable(
      (request.queryParameter('list').nullableJson as List<Object?>?)
          ?.map((i) => (i as num?)?.toInt())
          .toList(),
    );
    return result;
  });

  router.get('echo-map-nullable', (request) {
    var result = api.echoMapNullable(
      (request.queryParameter('map').nullableJson as Map<String, Object?>?)
          ?.map((k, v) => MapEntry(k, (v as num?)?.toInt())),
    );
    return result;
  });

  router.get('custom/<parameter>/<id>/<flag>', (request) async {
    var result = await api.withParameter(
      request.pathParameter('parameter').requiredString(),
      request.pathParameter('id').requiredInt(),
      request.pathParameter('flag').requiredBool(),
    );
    return result;
  });

  return router.handler;
}
