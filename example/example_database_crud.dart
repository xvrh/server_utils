import 'package:server_utils/database.dart';

import 'example_database_schema.dart';

extension ExampleDatabaseCrud on Database {
  AppUserCrud get appUser => AppUserCrud(this);
}

class AppUserCrud {
  final Database database;

  AppUserCrud(this.database);

  Future<AppUser> find(int id) async {
    // Options
    // - Inline SQL query
    await database.single(
      //language=sql
      'select * from app_user where id = :id',
      //language=none
      mapper: AppUser.fromRow,
      args: {'id': 'id'},
    );

    // - Use QueryBuilder
    // var query = SelectQueryBuilder().from('app_user').where('id', equals: '@id').build()

    // - Use simple utility function
    // var query = findSql('app_user', ['id'])

    throw UnimplementedError();
  }

  // All columns without primary key & optional when has default expression
  Future<AppUser> insert({
    required String role,
    required String email,
    DateTime? created,
    DateTime? lastSeen,
    required String countryCode,
    required int? configurationId,
    String? eulaVersion,
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    // No
    await database.single(
      //language=sql
      'insert into app_user (role, email) values (:role1, :email)',
      //language=none
      mapper: AppUser.fromRow,
      args: {'id': 'id'},
    );

    // Use a utility function to build the insert SQL with all the parameters
    // When they are not null

    throw UnimplementedError();
  }

  // Requires to set 0 on primary key & bad values on fields with Default expression.
  // => discard this option!
  // => Later, try to generate a AppUserBuilder entity with all fields nullable
  Future<AppUser> insertEntity(AppUser entity) async {
    throw UnimplementedError();
  }

  // All fields nullable (no update)
  // Add field "clearCountryCode" to set to null for Nullable fields
  Future<AppUser> updateFields(
    int id, {
    String? role,
    String? email,
    DateTime? created,
    DateTime? lastSeen,
    String? countryCode,
    int? configurationId,
    String? eulaVersion,
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    // Pass all values to a custom utility function that will build the query

    throw UnimplementedError();
  }

  // Requires a copyWith() method on the entity (with clearX methods)
  Future<AppUser> updateEntity(AppUser entity) async {
    // Same as updateFields,

    throw UnimplementedError();
  }

  Future<void> delete(int primaryKey) async {
    // Generate inline sql
    throw UnimplementedError();
  }

  //TODO(xha):
  // - Batch update?
}
