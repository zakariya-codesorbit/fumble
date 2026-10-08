import 'package:sqflite/sqflite.dart';

import '../models/pending_fumble_op.dart';
import 'local_database.dart';

/// On-device SQLite store for offline pending fumble operations.
class PendingFumbleLocalStore {
  PendingFumbleLocalStore({LocalDatabase? database})
      : _database = database ?? LocalDatabase.instance;

  final LocalDatabase _database;

  Future<void> insertPendingFumble(PendingFumbleOp op) async {
    final db = await _database.database;
    await db.insert(
      'pending_fumbles',
      {
        'id': op.id,
        'session_id': op.sessionId,
        'created_at': op.createdAt.millisecondsSinceEpoch,
        'attempt_count': op.attemptCount,
        'status': op.status.name,
        'last_error': op.lastError,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PendingFumbleOp>> loadAllPendingFumbles() async {
    final db = await _database.database;
    final rows = await db.query('pending_fumbles', orderBy: 'created_at ASC');
    return rows.map(_fromRow).toList();
  }

  Future<List<PendingFumbleOp>> loadPendingFumbles() async {
    final db = await _database.database;
    final rows = await db.query(
      'pending_fumbles',
      where: 'status = ?',
      whereArgs: [PendingOpStatus.pending.name],
      orderBy: 'created_at ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<void> savePendingFumble(PendingFumbleOp op) async {
    final db = await _database.database;
    await db.update(
      'pending_fumbles',
      {
        'attempt_count': op.attemptCount,
        'status': op.status.name,
        'last_error': op.lastError,
      },
      where: 'id = ?',
      whereArgs: [op.id],
    );
  }

  Future<void> removePendingFumble(String id) async {
    final db = await _database.database;
    await db.delete('pending_fumbles', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removePendingFumblesBySession(String sessionId) async {
    final db = await _database.database;
    await db.delete(
      'pending_fumbles',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  PendingFumbleOp _fromRow(Map<String, Object?> row) {
    return PendingFumbleOp(
      id: row['id'] as String,
      sessionId: row['session_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      attemptCount: row['attempt_count'] as int,
      status: PendingOpStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => PendingOpStatus.pending,
      ),
      lastError: row['last_error'] as String?,
    );
  }
}
