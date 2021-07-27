import 'package:server_utils/src/database/orm/sql_file_parser.dart';
import 'package:test/test.dart';

void main() {
  test('Parse sql file', () {
    var content = '''
--# import '../some_url.dart';
--# myMethodName
select * from country;

--# otherMethod
several
line
of 
text

--# --
nothing

--# thirdMethod -> !
content
''';
    var file = parseSqlFile(content);

    expect(file.imports, ["import '../some_url.dart';"]);
    expect(file.queries, hasLength(3));
    var myMethod = file.queries[0];
    var otherMethod = file.queries[1];
    var thirdMethod = file.queries[2];

    expect(myMethod.method.name, 'myMethodName');
    expect(myMethod.query, 'select * from country;');

    expect(otherMethod.method.name, 'otherMethod');
    expect(otherMethod.query, '''
several
line
of 
text''');

    expect(thirdMethod.method.name, 'thirdMethod');
  });

  test('Method description', () {
    expect(parseMethod('myMethod'),
        MethodDescription('myMethod', Result(null, ResultType.all)));
    expect(parseMethod('myMethod ->'),
        MethodDescription('myMethod', Result(null, ResultType.all)));
    expect(parseMethod('myMethod -> !'),
        MethodDescription('myMethod', Result(null, ResultType.single)));
    expect(parseMethod('myMethod -> SomeType'),
        MethodDescription('myMethod', Result('SomeType', ResultType.all)));
  });

  test('Result type', () {
    expect(Result.parse('!'), Result(null, ResultType.single));
    expect(Result.parse('?'), Result(null, ResultType.singleOrNull));
    expect(Result.parse('SomeType'), Result('SomeType', ResultType.all));
    expect(
        Result.parse('lib.SomeType'), Result('lib.SomeType', ResultType.all));
    expect(Result.parse('@SomeType'),
        Result('SomeType', ResultType.all, isGenerated: true));
    expect(() => Result.parse('@lib.SomeType'), throwsA(anything));
    expect(Result.parse('Page<SomeType>'), Result('SomeType', ResultType.page));
    expect(Result.parse('Page<@SomeType>'),
        Result('SomeType', ResultType.page, isGenerated: true));
    expect(Result.parse('Page<>'), Result(null, ResultType.page));
    expect(Result.parse('List<SomeType>'), Result('SomeType', ResultType.list));
    expect(Result.parse('List<@SomeType>'),
        Result('SomeType', ResultType.list, isGenerated: true));
    expect(Result.parse('List<>'), Result(null, ResultType.list));
    expect(() => Result.parse('<SomeType>'), throwsA(anything));
    expect(() => Result.parse('Unknown<SomeType>'), throwsA(anything));
    expect(
        Result.parse('SomeType?'), Result('SomeType', ResultType.singleOrNull));
    expect(Result.parse('@SomeType?'),
        Result('SomeType', ResultType.singleOrNull, isGenerated: true));
    expect(Result.parse('SomeType!'), Result('SomeType', ResultType.single));
    expect(Result.parse('@SomeType!'),
        Result('SomeType', ResultType.single, isGenerated: true));
  });
}
