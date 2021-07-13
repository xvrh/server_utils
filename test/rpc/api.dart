import 'package:json_annotation/json_annotation.dart';
import 'package:shelf/shelf.dart';
import 'package:server_utils/rpc.dart';
import 'package:server_utils/src/rpc_builder/annotations.dart';
import 'package:shelf_router/shelf_router.dart';

part 'api.g.dart';

@Api('news')
class NewsApi {
  void mountTo(Router router) {
    router.mount($newsApi.path, _$NewsApiHandler(this));
  }

  @Get()
  Future<String> simpleString() async => 'Hello';

  @Get()
  Future<String> greeting(String name) async => 'Hello $name';

  @Get()
  Future<String> greetingWithNamed(String name,
          {String? prefix, String? suffix}) async =>
      '${prefix ?? ''}Hello $name${suffix ?? ''}';

  @Get()
  Future<String> greetingWithRequired({required int count}) async =>
      'Hello' * count;

  @Get()
  Future<String> allTypes({
    int? aInt,
    required int requiredInt,
    bool? aBool,
    required bool requiredBool,
    num? aNum,
    required num requiredNum,
    double? aDouble,
    required double requiredDouble,
    String? aString,
    required String requiredString,
    DateTime? aDate,
    required DateTime requiredDate,
  }) async =>
      '$aInt $requiredInt $aBool $requiredBool $aNum $requiredNum $aDouble $requiredDouble $aString $requiredString ${aDate?.year} ${requiredDate.year}';

  @Get()
  Future<String> getList(
          List<int> ints, List<bool> bools, List<String> strings) async =>
      '$ints $bools $strings';

  @Get()
  Future<String> getListNullableValue(
          List<int?> ints, List<bool?> bools, List<String?> strings) async =>
      '$ints $bools $strings';

  @Get()
  Future<String> getListNullable(
          List<int?>? ints, List<bool?>? bools, List<String?>? strings) async =>
      '$ints $bools $strings';

  @Get()
  Future<String> getMap(Map<String, int> ints, Map<String, bool> bools,
          Map<String, String> strings) async =>
      '$ints $bools $strings';

  @Post()
  Future<String> postList(
          List<int> ints, List<bool> bools, List<String> strings) async =>
      '$ints $bools $strings';

  @Post()
  Future<String> postMap(Map<String, int> ints, Map<String, bool> bools,
          Map<String, String> strings) async =>
      '$ints $bools $strings';

  @Get()
  Future<List<News>> lastNews({int? count}) async {
    count ??= 2;
    return List.generate(count, (i) => News(i, title: 'News $i'));
  }

  @Post()
  Future<News> echo(News news) async {
    return news;
  }

  @Post()
  Future<List<News>> sendReceiveNewsPost(List<News> news) async {
    return news;
  }

  @Get()
  Future<List<News>> sendReceiveNewsGet(List<News> news) async {
    return news;
  }

  @Post()
  Future<Map<String, News>> sendReceiveMapNewsPost(
      Map<String, News> news) async {
    return news;
  }

  @Get()
  Future<Map<String, News>> sendReceiveMapNewsGet(
      Map<String, News> news) async {
    return news;
  }

  @Get()
  Future<List<String>> getListString() async {
    return ['a', 'b'];
  }

  @Post()
  Future<List<String>> getListStringPost() async {
    return ['a', 'b'];
  }

  @Get()
  List<bool> getListBool() => [true, false];

  @Post()
  List<bool> getListBoolPost() => [true, false];

  @Post()
  void aVoid(int id) {}

  @Get()
  bool returnBool() => true;

  @Get()
  num returnNum() => 3;

  @Get()
  double returnDouble() => 3;

  @Get()
  int returnInt() => 3;

  @Get()
  DateTime returnDateTime() => DateTime(2019, 8, 2);

  @Get()
  List<DateTime> returnListDateTime() => [DateTime(2019, 8, 2)];

  @Get()
  Future<List<DateTime>> returnFutureListDateTime() async =>
      [DateTime(2019, 8, 2)];

  @Get()
  List<MoveType?> echoEnum(MoveType type1, {MoveType? type2}) => [type1, type2];

  @Get()
  Page<News> getPage() {
    return Page<News>(3)..content = [News(2), News(3)];
  }

  @Get()
  Map<String, Page<News>> getPagesMap() {
    return {
      'a': Page<News>(3)..content = [News(2), News(3)]
    };
  }

  @Get()
  List<Page<News>> getPagesList() {
    return [
      Page<News>(3)..content = [News(2), News(3)]
    ];
  }

  @Get()
  void throwAnException() => throw Exception('An error');

  @Post()
  void throwANotFoundException() =>
      throw NotFoundException.resource('A resource');

  @Post()
  void throwAInvalidInputException() =>
      InvalidInputException.check(false, 'Invalid input');

  @Post()
  void throwOtherException({required int d1}) =>
      throw OtherException('A resource', d1: d1);

  @Get()
  List<int?> echoList(List<int?> list) => list;

  @Get()
  Map<String?, int?> echoMap(Map<String?, int?> map) => map;

  @Get()
  List<int?>? echoListNullable(List<int?>? list) => list;

  @Get()
  Map<String?, int?>? echoMapNullable(Map<String?, int?>? map) => map;

  Handler get handler => _$NewsApiHandler(this);
}

@JsonSerializable()
class News {
  int id;
  String? title;
  String? body;
  String? author;
  MoveType? moveType;

  News(this.id, {this.title});

  static News fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);

  Map<String, dynamic> toJson() => _$NewsToJson(this);
}

@JsonSerializable()
class Page<TContent> {
  final int size;

  @JsonKey(ignore: true)
  late List<TContent> content;

  Page(this.size);

  factory Page.fromJson(Map<String, dynamic> json,
          {required TContent Function(dynamic) contentReviver}) =>
      _$PageFromJson<TContent>(json)
        ..content = (json['content'] as List).map(contentReviver).toList();

  Map<String, dynamic> toJson() => _$PageToJson(this)..['content'] = content;
}

enum MoveType { inside, after, before }

class OtherException extends RpcException {
  OtherException(String message, {required int d1})
      : super(500, message, data: {'d1': d1});
}
