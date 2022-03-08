import 'package:server_utils/src/database/orm/utils/sql_parser.dart';
import 'package:test/test.dart';

void main() {
  test('Extract parameters from sql (1)', () {
    var query = SqlQuery.parse(
        '''select *::text /* :where */ ":id2" ' :id3::text ' id = :id''');
    expect(query.parameters, hasLength(1));
    expect(query.parameters[0].name, 'id');
    expect(query.parameters[0].type, isNull);
  });

  test('Extract parameters from sql (2)', () {
    var query = SqlQuery.parse('select * where id = :id::text');
    expect(query.parameters, hasLength(1));
    expect(query.parameters[0].name, 'id');
    expect(query.parameters[0].type, 'text');
  });

  test('Extract parameters from sql (3)', () {
    var query = SqlQuery.parse('select * where id = :id::text[] or');
    expect(query.parameters, hasLength(1));
    expect(query.parameters[0].name, 'id');
    expect(query.parameters[0].type!, 'text[]');
  });

  test('Extract parameters from sql (4)', () {
    var query = SqlQuery.parse(
        'select * where id = :id or id2 = :otherName::int order by');
    expect(query.parameters, hasLength(2));
    expect(query.parameters[0].name, 'id');
    expect(query.parameters[1].name, 'otherName');
  });

  test('Extract parameters from sql (5)', () {
    var query = SqlQuery.parse('select * where id = :id:_json::text');
    expect(query.parameters, hasLength(1));
    expect(query.parameters[0].name, 'id');
    expect(query.parameters[0].type, 'text');
  });

  test('Replace parameters 1', () {
    expect(
      SqlQuery.parse('select * id = :id').bodyWithDartSubstitutions,
      'select * id = @id',
    );
    expect(
      SqlQuery.parse(':id select * id = :id').bodyWithDartSubstitutions,
      '@id select * id = @id',
    );
    expect(
      SqlQuery.parse(':id select * id = :id:_json').bodyWithDartSubstitutions,
      '@id select * id = @id:_json',
    );
    expect(
      SqlQuery.parse(':id select * id = :id:_json::jsonb')
          .bodyWithDartSubstitutions,
      '@id select * id = @id:_json::jsonb',
    );
    expect(SqlQuery.parse(':id').bodyWithDartSubstitutions, '@id');
    expect(SqlQuery.parse(' :id ').bodyWithDartSubstitutions, ' @id');
    expect(SqlQuery.parse('''
select 
    * /*:id2*/
    id = 
    :id
''').bodyWithDartSubstitutions, '''
select 
    * /*:id2*/
    id = 
    @id''');
  });

  test('Replace parameters 2', () {
    expect(
      SqlQuery.parse('select * id = :id:int8').bodyWithStandardSubstitutions,
      'select * id = :id',
    );
    expect(
      SqlQuery.parse('select * id = :id:int8 and other')
          .bodyWithStandardSubstitutions,
      'select * id = :id and other',
    );
    expect(
      SqlQuery.parse('select * id = :id:int8::int')
          .bodyWithStandardSubstitutions,
      'select * id = :id::int',
    );
  });

  test('Dart substitutions', () {
    var sql = '''
select table_name::text
from information_schema.tables
where table_schema = :schemaName::text;
''';
    expect(SqlQuery.parse(sql).bodyWithDartSubstitutions, '''
select table_name::text
from information_schema.tables
where table_schema = @schemaName::text''');
  });

  test('SqlParser without colon', () {
    var sql = 'select count(*) from actor';
    var query = SqlQuery.parse(sql);
    expect(query.body, sql);
  });

  test('SqlParser with @ for parameters', () {
    var sql = 'select * from customers where customer_id = @customerId';
    var query = SqlQuery.parse(sql);
    expect(query.body, sql);
    expect(query.parameters, hasLength(1));
    expect(query.parameters[0].name, 'customerId');
    expect(query.parameters[0].type, isNull);
  });

  test('SqlParser with leading _', () {
    var sql = 'select count(*) as c from _migration_history';
    var query = SqlQuery.parse(sql);
    expect(query.body, sql);
  });
}
