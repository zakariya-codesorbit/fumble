import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/config/app_config.dart';

/// Local SQLite for connections and the legacy offline fumble queue.
class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConfig.databaseFileName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createPendingFumbles(db);
        await _createConnections(db);
      },
    );
  }

  static Future<void> _createPendingFumbles(Database db) {
    return db.execute('''
      CREATE TABLE IF NOT EXISTS pending_fumbles (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL,
        attempt_count INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        last_error TEXT
      )
    ''');
  }

  static Future<void> _createConnections(Database db) {
    return db.execute('''
      CREATE TABLE IF NOT EXISTS connections (
        owner_uid TEXT NOT NULL,
        peer_uid TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL DEFAULT '',
        photo_url TEXT,
        bio TEXT,
        phone TEXT,
        share_phone INTEGER NOT NULL DEFAULT 1,
        share_email INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        sync_status TEXT NOT NULL,
        PRIMARY KEY (owner_uid, peer_uid)
      )
    ''');
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
