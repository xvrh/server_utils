import 'package:faker/faker.dart';
import 'package:server_utils/database.dart';

// ignore_for_file: file_names
Future<void> migrate(MigrationContext context) async {
  var db = context.connection!;

  for (var i = 0; i < 100; i++) {
    await db.execute(
        'insert into actor (first_name, last_name) values (@firstName, @lastName);',
        substitutionValues: {
          'firstName': faker.person.firstName(),
          'lastName': faker.person.lastName(),
        });
  }

  await context.client.execute(List.generate(
          100, (i) => "insert into film (name, year) values ('a', $i);")
      .join('\n'));
}
