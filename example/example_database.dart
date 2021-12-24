import 'package:server_utils/database.dart';

final exampleDatabaseSuperUser = Postgres(
    Postgres.createDataPath('server_utils_example_database'),
    port: 8888);
