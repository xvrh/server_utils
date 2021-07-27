// Lib
import 'package:server_utils/src/database/page.dart';

import '../database.dart';

class Query<TReturn> {
  final String sql;
  final Map<String, dynamic> arguments;

  Query(this.sql, this.arguments);

  Future<TReturn> get single => throw UnimplementedError();
  Future<TReturn?> get singleOrNull => throw UnimplementedError();
  Future<List<TReturn>> get list => throw UnimplementedError();
  Future<Page<TReturn>> page(PageRequest page) => throw UnimplementedError();
}

// .sql
/*
--# generate queries

--# allUsers -> AppUser
select * from app_users;

--# allEmails
-- Returns is detected automatically
select email from app_users;

--# emailInLanguage -> @EmailRow
select id, email from app_users where language = :language::text;

--# emailInLanguage -> @EmailRow?
--# emailInLanguage -> List<@EmailRow>
--# emailInLanguage -> Page<@EmailRow>
--# emailInLanguage -> Page<>
--# emailInLanguage -> @EmailRow!
--# emailInLanguage -> !
--# emailInLanguage
select id, email from app_users where language = :language::text;

*/

// Décisions on the .sql file
// - Extension is .sql and is auto applied on all the files
// - Syntax of each query starts with --# methodName
// - Arguments are automatically extracted and must be typed (or throw an exception at compile time)
// - Return type can be ommited, in which case it is automatically inferred
//      (either it is an existing table already generated or it will be generated on the fly using
//      with the name MethodNameRow).
// - Return type can be specified with --# methodName -> ReturnType
// - Return type can be prefixed with @ to specify that the type should be generated
// - File can contains --# import '../other_file.dart'; statements
// - Eventually, the type of return type can be specified (single, singleOrNull, list, page).
//     then, the method doesn't return a Query but directly the final type.

// GENERATED

/*
class MyProjection {}

extension MyQueries on Database {
  Query<MyProjection> allUsers<MyProjection>({required String language}) {
    return Query<MyProjection>(
        'select * from app_users', {'language': language});
  }

  Future<List<MyProjection>> allUsers2<MyProjection>(
      {required String language}) {
    return Query<MyProjection>(
        'select * from app_users', {'language': language}).list;
  }
}
*/
