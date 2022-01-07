import 'package:server_utils/database.dart';

final exampleDatabaseServer =
    Postgres(Postgres.createDataPath('local_database'), port: 8888);

const exampleDatabaseName = 'example_database';
