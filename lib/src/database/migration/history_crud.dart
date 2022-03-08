// GENERATED-FILE

import 'package:server_utils/database.dart';
import 'history_schema.dart';

extension DatabaseCrudExtension on Database {
  MigrationHistoryCrud get migrationHistory => MigrationHistoryCrud(this);
}

class MigrationHistoryCrud {
  final Database _database;

  MigrationHistoryCrud(this._database);

  Future<MigrationHistory> find(int id) {
    return _database.single(
      //language=sql
      'select * from _migration_history where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
      mapper: MigrationHistory.fromRow,
    );
  }

  Future<MigrationHistory?> findOrNull(int id) {
    return _database.singleOrNull(
      //language=sql
      'select * from _migration_history where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
      mapper: MigrationHistory.fromRow,
    );
  }

  Future<MigrationHistory> insert({
    int? id /* nextval('_migration_history_id_seq'::regclass) */,
    required String name,
    DateTime? date /* now() */,
  }) {
    return _database.insert(
      MigrationHistory.table,
      values: {
        if (id != null) 'id': id,
        'name': name,
        if (date != null) 'date': date,
      },
      mapper: MigrationHistory.fromRow,
    );
  }

  Future<MigrationHistory> update(
    int id, {
    String? name,
    DateTime? date,
  }) {
    return _database.update(
      MigrationHistory.table,
      where: {
        'id': id,
      },
      set: {
        if (name != null) 'name': name,
        if (date != null) 'date': date,
      },
      mapper: MigrationHistory.fromRow,
    );
  }

  Future<MigrationHistory> updateEntity(MigrationHistory entity) {
    return update(
      entity.id,
      name: entity.name,
      date: entity.date,
    );
  }

  Future<int> delete(int id) {
    return _database.execute(
      //language=sql
      'delete from _migration_history where id = :id::integer',
      //language=none
      args: {
        'id': id,
      },
    );
  }
}
