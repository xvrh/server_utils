import '../../../database.dart';
import 'history_schema.dart';

part 'history.queries.gen.dart';

extension _HistoryQueries on Database {
  bool tableExists(String tableName, {String schemaName = 'public'}) {
    //language=sql
    q(r'''
select exists(
               select 1
               from information_schema.tables
               where table_schema = :schemaName::text
                 and table_name = :tableName::text
           )
''');
  }

  List<MigrationHistory> listMigrations() {
    //language=sql
    q(r'''
select * from _migration_history
''');
  }
}
