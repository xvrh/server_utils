import 'dart:io';
import 'package:http/http.dart';
import 'package:server_utils/rpc_client.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';
import 'api.dart';
import 'api.g.client.dart' as client_lib;

void main() {
  late HttpServer server;
  late client_lib.NewsController client;

  setUpAll(() async {
    var router = Router();
    router.mount($newsController.path, NewsController().handler);
    server = await io.serve(router, InternetAddress.anyIPv4, 0);
  });

  tearDownAll(() async {
    await server.close();
  });

  setUp(() {
    client = client_lib.NewsController(Client(),
        basePath: '${'http'}://${server.address.host}:${server.port}');
  });

  tearDown(() {
    client.close();
  });

  test('Simple string', () async {
    var result = await client.simpleString();
    expect(result, equals('Hello'));
  });

  test('Send parameter', () async {
    var result = await client.greeting('X');
    expect(result, equals('Hello X'));
  });

  test('Send named parameter', () async {
    var result = await client.greetingWithNamed('X', suffix: '!');
    expect(result, equals('Hello X!'));
  });

  test('Null required argument should works', () async {
    expect(await client.greetingWithRequired(count: 2), equals('HelloHello'));
  });

  test('Can send all primitive types', () async {
    var result = await client.allTypes(
      aInt: 2,
      requiredInt: 3,
      aBool: true,
      requiredBool: false,
      aNum: 3,
      requiredNum: 4,
      aDouble: 5.0,
      requiredDouble: 6.5,
      aString: 'X',
      requiredString: 'Y',
      aDate: DateTime(2019, 7, 27),
      requiredDate: DateTime(2020, 7, 27),
    );
    expect(result, equals('2 3 true false 3 4 5.0 6.5 X Y 2019 2020'));
  });

  test('Can send List with get method', () async {
    var result = await client.getList([2, 3], [true, false], ['A', 'B']);
    expect(result, equals('[2, 3] [true, false] [A, B]'));
  });

  test('Can send Map with get method', () async {
    var result = await client.getMap(
        {'2': 2, '3': 3}, {'t': true, 'f': false}, {'a': 'A', 'b': 'B'});
    expect(result, equals('{2: 2, 3: 3} {t: true, f: false} {a: A, b: B}'));
  });

  test('Can send List with post method', () async {
    var result = await client.postList([2, 3], [true, false], ['A', 'B']);
    expect(result, equals('[2, 3] [true, false] [A, B]'));
  });

  test('Can send Map with post method', () async {
    var result = await client.postMap(
        {'2': 2, '3': 3}, {'t': true, 'f': false}, {'a': 'A', 'b': 'B'});
    expect(result, equals('{2: 2, 3: 3} {t: true, f: false} {a: A, b: B}'));
  });

  test('Can send and receive complex type', () async {
    var response = await client
        .echo(News(3, title: 'The title')..moveType = MoveType.after);
    expect(response.title, equals('The title'));
    expect(response.moveType, equals(MoveType.after));
    expect(response.id, equals(3));
  });

  test('Can send and receive List of complex type', () async {
    var response = await client.sendReceiveNewsPost(
        [News(3, title: 'The title'), News(4, title: 'The title 4')]);
    expect(response, hasLength(2));
    expect(response[0].id, equals(3));
    expect(response[0].title, equals('The title'));
    expect(response[1].title, equals('The title 4'));
  });

  test('Can send and receive List of complex type', () async {
    var response = await client.sendReceiveNewsGet(
        [News(3, title: 'The title'), News(4, title: 'The title 4')]);
    expect(response, hasLength(2));
    expect(response[0].id, equals(3));
    expect(response[0].title, equals('The title'));
    expect(response[1].title, equals('The title 4'));
  });

  test('Can send and receive Map of complex type', () async {
    var map = <String, News>{
      'a': News(3, title: 'aa'),
      'b': News(4, title: 'bb'),
    };

    var response = await client.sendReceiveMapNewsGet(map);
    expect(response, hasLength(2));
    expect(response['a']!.id, equals(3));
    expect(response['a']!.title, equals('aa'));

    response = await client.sendReceiveMapNewsPost(map);
    expect(response, hasLength(2));
    expect(response['a']!.id, equals(3));
    expect(response['b']!.id, equals(4));
  });

  test('Can get List<String>', () async {
    expect(await client.getListString(), equals(['a', 'b']));
    expect(await client.getListStringPost(), equals(['a', 'b']));
  });

  test('Can get List<bool>', () async {
    expect(await client.getListBool(), equals([true, false]));
    expect(await client.getListBoolPost(), equals([true, false]));
  });

  test('Can return void', () async {
    await client.aVoid(3);
  });

  test('Can return primitive', () async {
    expect(await client.returnBool(), isTrue);
    expect(await client.returnDouble(), equals(3.0));
    expect(await client.returnNum(), equals(3));
    expect(await client.returnInt(), equals(3));
    expect(await client.returnDateTime(), equals(DateTime(2019, 8, 2)));
    expect(await client.returnListDateTime(), equals([DateTime(2019, 8, 2)]));
    expect(await client.returnFutureListDateTime(),
        equals([DateTime(2019, 8, 2)]));
  });

  test('Can return generic type', () async {
    var page = await client.getPage();
    expect(page.size, equals(3));
    expect(page.content, hasLength(2));
    expect(page.content[0].id, equals(2));
  });

  test('Can return Map of generic type', () async {
    var pages = await client.getPagesMap();
    expect(pages, hasLength(1));
    var page = pages.values.first;
    expect(page.size, equals(3));
    expect(page.content, hasLength(2));
    expect(page.content[0].id, equals(2));
  });

  test('Can return List of generic type', () async {
    var pages = await client.getPagesList();
    expect(pages, hasLength(1));
    var page = pages.first;
    expect(page.size, equals(3));
    expect(page.content, hasLength(2));
    expect(page.content[0].id, equals(2));
  });

  test('Rethrow server error', () async {
    expect(client.throwAnError,
        throwsA(predicate((e) => '$e'.contains('An error'))));
    expect(client.throwAnError, throwsA(isA<RpcException>()));
    expect(client.throwAnError,
        throwsA(predicate((RpcException e) => e.internalError != null)));
  });

  test('Can transfer enum', () async {
    expect(await client.echoEnum(MoveType.inside, type2: MoveType.before),
        equals([MoveType.inside, MoveType.before]));
  });

  test('Nullable list', () async {
    var list = [1, null, 2];
    expect(await client.echoList(list), list);
  });

  test('Nullable map', () async {
    var map = <String?, int?>{'0': 1, '2': null, '3': 4};
    expect(await client.echoMap(map), map);
  });

  test('List map null', () async {
    expect(await client.echoListNullable(null), null);
    expect(await client.echoMapNullable(null), null);
  });
}
