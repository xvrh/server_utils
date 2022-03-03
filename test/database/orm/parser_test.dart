import 'package:server_utils/src/database/orm/utils/sql_parser.dart';
import 'package:test/test.dart';

void main() {
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
    expect(result.body, query.substring(0, query.length - 1));
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
    expect(result.body, 'select * from table');
    expect(result.parameters, isEmpty);
  });

  test('Parse query with ;', () {
    var query = 'select * from table;/*bla */';
    var result = SqlQuery.parse(query);
    expect(result.body, 'select * from table');
    expect(result.parameters, isEmpty);
  });
}
