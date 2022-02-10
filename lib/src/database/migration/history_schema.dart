// GENERATED-FILE
import 'package:server_utils/database.dart';

class MigrationHistory {
  static final columns = _MigrationHistoryColumns();

  final int id;
  final String name;
  final DateTime date;

  MigrationHistory({
    required this.id,
    required this.name,
    required this.date,
  });

  factory MigrationHistory.fromRow(Map<String, dynamic> row) {
    return MigrationHistory(
      id: row['id']! as int,
      name: row['name']! as String,
      date: row['date']! as DateTime,
    );
  }

  factory MigrationHistory.fromJson(Map<String, Object?> json) {
    return MigrationHistory(
      id: (json['id']! as num).toInt(),
      name: json['name']! as String,
      date: DateTime.parse(json['date']! as String),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
    };
  }

  MigrationHistory copyWith({
    int? id,
    String? name,
    DateTime? date,
  }) {
    return MigrationHistory(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
    );
  }
}

class _MigrationHistoryColumns {
  final id = Column<MigrationHistory>('id');
  final name = Column<MigrationHistory>('name');
  final date = Column<MigrationHistory>('date');
  late final list = [id, name, date];
}
