import 'package:sqflite/sqflite.dart';

import '../db/local_database.dart';
import '../models/connection.dart';

/// On-device SQLite store for the owner's connections list.
class ConnectionLocalStore {
  ConnectionLocalStore({LocalDatabase? database})
      : _local = database ?? LocalDatabase.instance;

  final LocalDatabase _local;

  Future<bool> exists({
    required String ownerUid,
    required String peerUid,
  }) async {
    final db = await _local.database;
    final rows = await db.query(
      'connections',
      columns: const ['peer_uid'],
      where: 'owner_uid = ? AND peer_uid = ?',
      whereArgs: [ownerUid, peerUid],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<Connection>> loadAllForOwner(String ownerUid) async {
    final db = await _local.database;
    final rows = await db.query(
      'connections',
      where: 'owner_uid = ?',
      whereArgs: [ownerUid],
      orderBy: 'created_at DESC',
    );
    return rows.map(Connection.fromLocalRow).toList();
  }

  Future<Connection?> loadOne({
    required String ownerUid,
    required String peerUid,
  }) async {
    final db = await _local.database;
    final rows = await db.query(
      'connections',
      where: 'owner_uid = ? AND peer_uid = ?',
      whereArgs: [ownerUid, peerUid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Connection.fromLocalRow(rows.first);
  }

  /// Inserts a new row. Returns false if that peer is already saved.
  Future<bool> insertIfAbsent(String ownerUid, Connection connection) async {
    final db = await _local.database;
    try {
      await db.insert(
        'connections',
        connection.toLocalRow(ownerUid),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return true;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) return false;
      rethrow;
    }
  }

  Future<void> save(String ownerUid, Connection connection) async {
    final db = await _local.database;
    await db.insert(
      'connections',
      connection.toLocalRow(ownerUid),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSyncStatus({
    required String ownerUid,
    required String peerUid,
    required SyncStatus status,
  }) async {
    final db = await _local.database;
    await db.update(
      'connections',
      {
        'sync_status': status.name,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'owner_uid = ? AND peer_uid = ?',
      whereArgs: [ownerUid, peerUid],
    );
  }

  Future<void> remove({
    required String ownerUid,
    required String peerUid,
  }) async {
    final db = await _local.database;
    await db.delete(
      'connections',
      where: 'owner_uid = ? AND peer_uid = ?',
      whereArgs: [ownerUid, peerUid],
    );
  }
}
