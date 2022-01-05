import 'package:petitparser/petitparser.dart';
import 'package:server_utils/src/database/orm/utils/sql_parser.dart';
import 'package:test/test.dart';
import 'package:server_utils/src/database/orm/queries_parser.dart';

void main() {
  test('Complete parser', () {
    var result = parseQueries('''
-- Normal comment
--Other comment
/*
 Explanatation
*/
--@extension ExtensionName /* See this
 ok?
 */
/* Other explanation */
--@class Blabla --ok?
--@import 'package:bla/bla.dart' show XX as yy;
--@class--empty

-- Between 

/**
xx.Page<Output> allColumn()
testValues = {
  id: 'value',
}
**/
select * from machin where id=:id::text;

/*******************************
List<yy.Output> oneCol(String name,)/* After*/
testValues = {
  name: 12.2,
  name: 12,
  name: true,
  name: false,
  name: null,
  name: 'null',
}
projection Output (
  /* comment */
  one_column not null,
)
********************************/
-- Somme comment
select * /* not null */from machin;

/**
String? columnName({ required String? name= 'public',}) // End
projection Name ( * not null, name null as TranslatedString, name2 null )
**/
select * from machin;
''');

    expect(result.isSuccess, isTrue);

    expect((result.value.directives[0] as ExtensionDirective).name!.name,
        'ExtensionName');
    expect((result.value.directives[1] as ClassDirective).name!.name, 'Blabla');
    expect((result.value.directives[2] as ImportDirective).body,
        "'package:bla/bla.dart' show XX as yy");
    expect((result.value.directives[3] as ClassDirective).name, isNull);

    var columnNameQuery = result.value.queries
        .firstWhere((e) => e.header.method.name == 'columnName');
    var projection = columnNameQuery.header.projection!;
    expect(projection.lines, hasLength(3));
    expect(projection.lines.first.columnName, isNull);
    var nameLine =
        projection.lines.firstWhere((e) => e.columnName?.name == 'name');
    expect(nameLine.modifiers, hasLength(2));
    expect(nameLine.modifiers[0], isA<ProjectionModifierNull>());
    expect(nameLine.modifiers[1], isA<ProjectionModifierAs>());
    expect((nameLine.modifiers[1] as ProjectionModifierAs).type.name,
        'TranslatedString');

    var oneColQuery = result.value.queries
        .firstWhere((e) => e.header.method.name == 'oneCol');
    expect(oneColQuery.header.testValues!.values[0].name.name, 'name');
    expect(oneColQuery.header.testValues!.values[0].value, 12.2);
    expect(oneColQuery.header.testValues!.values[1].value, 12);
    expect(oneColQuery.header.testValues!.values[2].value, true);
    expect(oneColQuery.header.testValues!.values[3].value, false);
    expect(oneColQuery.header.testValues!.values[4].value, null);
    expect(oneColQuery.header.testValues!.values[5].value, 'null');
  });

  test('Parse Dart parameters', () {
    var definition = DartAstDefinition();
    var parser = definition.build(start: definition.functionDeclaration);
    var result =
        parser.parse('Output methodName(String p1, {required int p2, num? p3})')
            as Result<MethodDeclaration>;
    expect(result.isSuccess, true);
    var value = result.value;
    expect(value.returnType, 'Output');
    expect(value.name, 'methodName');
    expect(value.parameters.rawDeclaration,
        '(String p1, {required int p2, num? p3})');
    expect(value.parameters.parameters, [
      DartParameter('p1', 'String'),
      DartParameter('p2', 'int'),
      DartParameter('p3', 'num?')
    ]);
  });

  test('Can comment top level', () {
    var result = parseQueries('''
--@extension
/*
commented
/******
Output commentedOut()
*******/
*/

/******
Output ok()
*******/

/*
commented
/******
Output commentedOut2()
*******/
*/
''');

    expect(result.isSuccess, isTrue);
    expect((result.value.directives[0] as ExtensionDirective).name, isNull);
    expect(result.value.queries, hasLength(1));
    expect(result.value.queries[0].header.method.name, 'ok');
  });

  test('Parse sql query', () {
    var query = r'''
select f.*, * /* :ignore::text */
case ':ign''ore\t2':
  as f.xx[] 'inner:-;' (query)={2,3} || dd && dd
  $$ bla
  :ignore
  ba
  $$
  $start$
    This can go^° à wild
  $start$
  :id :id2::text :id3::int[] :id4:type
  Select * from Employee a where rowid <>( select max(rowid) from Employee b where a.Employee_num=b.Employee_num)
  CREATE FUNCTION doubledollarinbody(var1 text) RETURNS text
/* see issue277 */
LANGUAGE plpgsql
AS
DECLARE
  str text
  BEGIN
    str = $$'foo'$$||var1
    execute 'select '||str into str
    return str
  END
  ARRAY[[1,2],[3,4]];''';
    var result = SqlQuery.parse(query);
    expect(result.body, query);
    expect(result.parameters[0].name, 'id');
    expect(result.parameters[0].type, isNull);
    expect(result.parameters[1].name, 'id2');
    expect(result.parameters[1].type!, 'text');
    expect(result.parameters[2].name, 'id3');
    expect(result.parameters[2].type!, 'int[]');
  });

  test('Parse query without ;', () {
    var query = 'select * from table';
    var result = SqlQuery.parse(query);
    expect(result.body, query);
    expect(result.parameters, isEmpty);
  });

  test('Parse queries with position', () {
    var result = parseQueries('''
/**
String? columnName(int id)
**/

select * from machin where id = :id;
''');
    expect(result.isSuccess, isTrue);
    var file = result.value;
    var query = file.queries.first;
    expect(query.query.bodyWithDartSubstitutions,
        'select * from machin where id = @id;');
  });
}
