import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:tera_assistente/data/models.dart';
import 'package:tera_assistente/data/profession_seed.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'tera_assistente.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: (database, version) async => _createTables(database),
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute('ALTER TABLE records ADD COLUMN updated_at TEXT');
          await database.execute('ALTER TABLE records ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0');
        }
        if (oldVersion < 3) {
          await database.execute('CREATE TABLE profession_toolkits(id INTEGER PRIMARY KEY AUTOINCREMENT,profession TEXT NOT NULL UNIQUE,category TEXT NOT NULL,tools_json TEXT NOT NULL,documents_json TEXT NOT NULL,routines_json TEXT NOT NULL,metrics_json TEXT NOT NULL)');
          await database.execute('CREATE TABLE daily_tasks(id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER NOT NULL,profession TEXT NOT NULL,title TEXT NOT NULL,done INTEGER NOT NULL DEFAULT 0,FOREIGN KEY(user_id) REFERENCES users(id))');
          for (final p in kProfessionPresets) {
            final kit = toolkitFor(p);
            await database.insert('profession_toolkits', {
              'profession': kit.profession,
              'category': kit.category,
              'tools_json': encodeList(kit.tools),
              'documents_json': encodeList(kit.documents),
              'routines_json': encodeList(kit.routines),
              'metrics_json': encodeList(kit.metrics),
            });
          }
        }
      },
    );
  }

  Future<void> _createTables(Database d) async {
    await d.execute('CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,email TEXT NOT NULL UNIQUE,profession TEXT NOT NULL,password_hash TEXT NOT NULL,created_at TEXT NOT NULL)');
    await d.execute('CREATE TABLE professions(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL UNIQUE,category TEXT NOT NULL,description TEXT NOT NULL)');
    await d.execute('CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER NOT NULL,profession TEXT NOT NULL,type TEXT NOT NULL,title TEXT NOT NULL,content TEXT NOT NULL,created_at TEXT NOT NULL,updated_at TEXT,is_favorite INTEGER NOT NULL DEFAULT 0,FOREIGN KEY(user_id) REFERENCES users(id))');
    await d.execute('CREATE TABLE profession_toolkits(id INTEGER PRIMARY KEY AUTOINCREMENT,profession TEXT NOT NULL UNIQUE,category TEXT NOT NULL,tools_json TEXT NOT NULL,documents_json TEXT NOT NULL,routines_json TEXT NOT NULL,metrics_json TEXT NOT NULL)');
    await d.execute('CREATE TABLE daily_tasks(id INTEGER PRIMARY KEY AUTOINCREMENT,user_id INTEGER NOT NULL,profession TEXT NOT NULL,title TEXT NOT NULL,done INTEGER NOT NULL DEFAULT 0,FOREIGN KEY(user_id) REFERENCES users(id))');

    for (final p in kProfessionPresets) {
      await d.insert('professions', {'name': p.name, 'category': p.category, 'description': p.description});
      final kit = toolkitFor(p);
      await d.insert('profession_toolkits', {
        'profession': kit.profession,
        'category': kit.category,
        'tools_json': encodeList(kit.tools),
        'documents_json': encodeList(kit.documents),
        'routines_json': encodeList(kit.routines),
        'metrics_json': encodeList(kit.metrics),
      });
    }
  }

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

  Future<bool> registerUser({required String name, required String email, required String profession, required String password}) async {
    final database = await db;
    try {
      await database.insert('users', {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'profession': profession,
        'password_hash': _hash(password),
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<User?> login({required String email, required String password}) async {
    final database = await db;
    final rows = await database.query('users', where: 'email = ? AND password_hash = ?', whereArgs: [email.trim().toLowerCase(), _hash(password)], limit: 1);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return User(id: r['id'] as int, name: r['name'] as String, email: r['email'] as String, profession: r['profession'] as String);
  }

  Future<List<ProfessionPreset>> getProfessions() async {
    final database = await db;
    final rows = await database.query('professions', orderBy: 'name ASC');
    return rows.map((r) => ProfessionPreset(name: r['name'] as String, category: r['category'] as String, description: r['description'] as String)).toList();
  }

  Future<ProfessionToolkit> getToolkit(String profession) async {
    final database = await db;
    final rows = await database.query('profession_toolkits', where: 'profession = ?', whereArgs: [profession], limit: 1);
    if (rows.isEmpty) {
      final p = kProfessionPresets.firstWhere((e) => e.name == 'Outro');
      return toolkitFor(p);
    }
    final r = rows.first;
    return ProfessionToolkit(
      profession: r['profession'] as String,
      category: r['category'] as String,
      tools: decodeList(r['tools_json'] as String),
      documents: decodeList(r['documents_json'] as String),
      routines: decodeList(r['routines_json'] as String),
      metrics: decodeList(r['metrics_json'] as String),
    );
  }

  Future<void> addRecord({required int userId, required String profession, required String type, required String title, required String content}) async {
    final d = await db;
    await d.insert('records', {'user_id': userId, 'profession': profession, 'type': type, 'title': title.trim(), 'content': content.trim(), 'created_at': DateTime.now().toIso8601String(), 'is_favorite': 0});
  }

  Future<void> updateRecord({required int id, required String profession, required String type, required String title, required String content}) async {
    final d = await db;
    await d.update('records', {'profession': profession, 'type': type, 'title': title.trim(), 'content': content.trim(), 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteRecord(int id) async {
    final d = await db;
    await d.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final d = await db;
    await d.update('records', {'is_favorite': isFavorite ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<WorkRecord>> getRecords(int userId, {String query = '', bool onlyFavorites = false}) async {
    final d = await db;
    final q = query.trim();
    final where = <String>['user_id = ?'];
    final args = <Object>[userId];
    if (q.isNotEmpty) {
      where.add('(title LIKE ? OR content LIKE ? OR profession LIKE ? OR type LIKE ?)');
      args.addAll(['%$q%', '%$q%', '%$q%', '%$q%']);
    }
    if (onlyFavorites) where.add('is_favorite = 1');

    final rows = await d.query('records', where: where.join(' AND '), whereArgs: args, orderBy: 'is_favorite DESC, created_at DESC');
    return rows
        .map((r) => WorkRecord(
              id: r['id'] as int,
              userId: r['user_id'] as int,
              profession: r['profession'] as String,
              type: r['type'] as String,
              title: r['title'] as String,
              content: r['content'] as String,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: r['updated_at'] == null ? null : DateTime.parse(r['updated_at'] as String),
              isFavorite: (r['is_favorite'] as int? ?? 0) == 1,
            ))
        .toList();
  }

  Future<void> seedDailyTasksForUser(int userId, String profession, List<String> routines) async {
    final d = await db;
    final count = Sqflite.firstIntValue(await d.rawQuery('SELECT COUNT(*) FROM daily_tasks WHERE user_id = ? AND profession = ?', [userId, profession])) ?? 0;
    if (count > 0) return;
    for (final r in routines) {
      await d.insert('daily_tasks', {'user_id': userId, 'profession': profession, 'title': r, 'done': 0});
    }
  }

  Future<List<DailyTask>> getDailyTasks(int userId, String profession) async {
    final d = await db;
    final rows = await d.query('daily_tasks', where: 'user_id = ? AND profession = ?', whereArgs: [userId, profession], orderBy: 'done ASC, id ASC');
    return rows.map((r) => DailyTask(id: r['id'] as int, userId: r['user_id'] as int, profession: r['profession'] as String, title: r['title'] as String, done: (r['done'] as int) == 1)).toList();
  }

  Future<void> setTaskDone(int id, bool done) async {
    final d = await db;
    await d.update('daily_tasks', {'done': done ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<String> exportUserSnapshotJson(int userId) async {
    final d = await db;
    final users = await d.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
    final records = await d.query('records', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    final tasks = await d.query('daily_tasks', where: 'user_id = ?', whereArgs: [userId]);
    final payload = {'exported_at': DateTime.now().toUtc().toIso8601String(), 'user': users.isEmpty ? null : users.first, 'records': records, 'tasks': tasks};
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
