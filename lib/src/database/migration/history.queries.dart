// GENERATED-CODE: do not edit
// Code is generated from history.queries.sql

import 'package:server_utils/database.dart';
import 'history_schema.dart';

extension HistoryQueries on Database {
  Future<bool> tableExists(String tableName, {String schemaName = 'public'}) {
    return Query<bool>.singleColumn(this,
        //language=sql
        r'''
select exists(
               select 1
               from information_schema.tables
               where table_schema = :schemaName::text
                 and table_name = :tableName::text
           )
''', arguments: {
      'tableName': tableName,
      'schemaName': schemaName,
    }).single;
  }

  Future<List<MigrationHistory>> listMigrations() {
    return Query<MigrationHistory>(
      this,
      //language=sql
      r'''
select * from _migration_history
''',
      arguments: {},
      mapper: MigrationHistory.fromRow,
    ).list;
  }
}
