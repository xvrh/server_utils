import 'package:server_utils/database.dart';

final exampleDatabaseSuperUser =
    Postgres(Postgres.createDataPath('local_database'), port: 8888);
