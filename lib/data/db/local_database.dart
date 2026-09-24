import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/config/app_config.dart';

/// Local SQLite for offline fumble queue.
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
        await db.execute('''
          CREATE TABLE pending_fumbles (
            id TEXT PRIMARY KEY,
            session_id TEXT NOT NULL UNIQUE,
            created_at INTEGER NOT NULL,
            attempt_count INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL,
            last_error TEXT
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
