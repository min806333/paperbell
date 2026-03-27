import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LifeAdminDatabaseService {
  LifeAdminDatabaseService({
    DatabaseFactory? databaseFactory,
    Future<String> Function()? databasePathBuilder,
  }) : _databaseFactoryOverride = databaseFactory,
       _databasePathBuilder = databasePathBuilder;

  static const databaseName = 'life_admin_assistant.db';
  static const databaseVersion = 3;

  final DatabaseFactory? _databaseFactoryOverride;
  final Future<String> Function()? _databasePathBuilder;

  Database? _database;

  Future<Database> open() async {
    if (_database != null) {
      return _database!;
    }

    final databaseFactory =
        _databaseFactoryOverride ?? _resolveDatabaseFactory();
    final databasePath =
        await (_databasePathBuilder?.call() ??
            _defaultDatabasePath(databaseFactory));

    _database = await databaseFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (database, version) async {
          await _createSchema(database);
        },
        onUpgrade: (database, oldVersion, newVersion) async {
          await _runMigrations(
            database,
            oldVersion: oldVersion,
            newVersion: newVersion,
          );
        },
      ),
    );

    return _database!;
  }

  Future<void> close() async {
    final database = _database;
    if (database == null) {
      return;
    }

    await database.close();
    _database = null;
  }

  DatabaseFactory _resolveDatabaseFactory() {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web builds do not support the local database yet.',
      );
    }

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      return databaseFactoryFfi;
    }

    return databaseFactory;
  }

  Future<String> _defaultDatabasePath(DatabaseFactory databaseFactory) async {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      final databaseDirectory = await databaseFactory.getDatabasesPath();
      return p.join(databaseDirectory, databaseName);
    }

    final directory = await getApplicationDocumentsDirectory();
    return p.join(directory.path, databaseName);
  }

  Future<void> _createSchema(DatabaseExecutor database) async {
    await database.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        source_type TEXT NOT NULL,
        title TEXT NOT NULL,
        original_path TEXT,
        created_at INTEGER NOT NULL,
        contains_sensitive INTEGER NOT NULL,
        rotation_quarter_turns INTEGER NOT NULL DEFAULT 0,
        crop_inset_ratio REAL NOT NULL DEFAULT 0
      )
    ''');

    await database.execute('''
      CREATE TABLE document_pages (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        preview_label TEXT NOT NULL,
        helper_text TEXT NOT NULL,
        FOREIGN KEY(document_id) REFERENCES documents(id) ON DELETE CASCADE
      )
    ''');

    await database.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        document_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        due_at INTEGER NOT NULL,
        amount REAL,
        currency TEXT,
        note TEXT,
        repeat_rule TEXT,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        source_subtitle TEXT NOT NULL,
        reminder_lead_days INTEGER NOT NULL,
        FOREIGN KEY(document_id) REFERENCES documents(id) ON DELETE RESTRICT
      )
    ''');

    await _createMetadataTable(database);
    await _createReminderIndex(database);
  }

  Future<void> _runMigrations(
    DatabaseExecutor database, {
    required int oldVersion,
    required int newVersion,
  }) async {
    if (oldVersion < 1 && newVersion >= 1) {
      await _createSchema(database);
    }

    if (oldVersion < 2 && newVersion >= 2) {
      await _createMetadataTable(database);
      await _createReminderIndex(database);
    }

    if (oldVersion < 3 && newVersion >= 3) {
      await database.execute(
        'ALTER TABLE documents ADD COLUMN rotation_quarter_turns INTEGER NOT NULL DEFAULT 0',
      );
      await database.execute(
        'ALTER TABLE documents ADD COLUMN crop_inset_ratio REAL NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> _createMetadataTable(DatabaseExecutor database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS app_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createReminderIndex(DatabaseExecutor database) async {
    await database.execute(
      'CREATE INDEX IF NOT EXISTS reminders_due_at_idx ON reminders(due_at)',
    );
  }
}
