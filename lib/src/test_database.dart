import 'package:server_utils/postgres.dart';

final thisPackageTestDatabase =
    Postgres(Postgres.createDataPath('server_utils_database'), port: 8888);
