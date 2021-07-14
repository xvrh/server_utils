import 'package:server_utils/src/database/start_script.dart';
import 'package:server_utils/src/test_database.dart';

void main() async {
  startDatabaseServer(thisPackageTestDatabase);
}
