import 'package:faker/faker.dart';
import 'package:server_utils/database.dart';

Future<void> migrate(MigrationContext context) async {
  var db = context.connection!;

  for (var i = 0; i < 100; i++) {
    await db.execute(
        'insert into app_user (email, country_code, role, first_name) values (@email, @country, @role, @firstName);',
        substitutionValues: {
          'email': faker.internet.email(),
          'country': 'BE',
          'firstName': faker.person.firstName(),
          'role': 'USER',
        });
  }
}
