import 'dart:io';
import 'package:postgres/postgres.dart';

abstract class MigrationClient {
  Future<T> runConnection<T>(
      Future<T> Function(PostgreSQLExecutionContext) callback);
  Future<void> executeFile(File file);
  MigrationContextCode migrationContext();
}

class MigrationContextCode {
  final String import;
  final String creationCode;

  MigrationContextCode(this.import, this.creationCode);
}

abstract class MigrationContext {
  PostgreSQLConnection get connection;
  Future<void> executeFile(File file);
  Future<void> execute(String script);
  Future<void> close();
}
