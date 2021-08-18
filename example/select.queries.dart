// GENERATED-CODE: do not edit
// Code is generated from select.queries.sql
import 'package:server_utils/database.dart';

extension SelectQueries on Database {
  Future<app_user> findUser() {
    return Query<app_user>(r'''
select * from app_user where id = :id::int;
''', {}).single;
  }

  Future<app_user> findUserByEmail() {
    return Query<app_user>(r'''
select * from app_user where email = :email::text;
''', {}).single;
  }

  Query<app_user> queryByCountry() {
    return Query<app_user>(r'''
select * from app_user where country_code = :country::text;
''', {});
  }

  Query<app_user> allNames() {
    return Query<app_user>(r'''
select first_name from app_user;
''', {});
  }
}
