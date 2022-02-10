--@import 'history_schema.dart';

/******************************
bool tableExists(String tableName, {String schemaName = 'public'})
*******************************/
select exists(
               select 1
               from information_schema.tables
               where table_schema = :schemaName::text
                 and table_name = :tableName::text
           );

/******************************
List<MigrationHistory> listMigrations()
*******************************/
select * from _migration_history;
