import 'package:server_utils/database.dart';

final testDatabaseSuperuser =
    Postgres(Postgres.createDataPath('server_utils_database'), port: 8888);
