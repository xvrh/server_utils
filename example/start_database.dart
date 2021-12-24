import 'package:server_utils/src/database/start_script.dart';
import 'example_database.dart';

void main() async {
  startDatabaseServer(exampleDatabaseSuperUser);
}
