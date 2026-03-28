import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/todo_model.dart';

class TodoDatabase {
  static Database? _db;

  // Get database instance
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // Initialize the database
  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            isDone INTEGER NOT NULL,
            isStarred INTEGER NOT NULL,
            isPinned INTEGER NOT NULL,
            dateTime TEXT NOT NULL,
            deletedAt TEXT,
            isSynced INTEGER,
            isDeleted INTEGER,
            isUpdated INTEGER
          )
        ''');
      },
    );
  }

  // Insert a new todo
  static Future<void> insertTodo(TodoModel todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update existing todo
  static Future<void> updateTodo(TodoModel todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toJson(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Fetch all todos
  static Future<List<TodoModel>> getTodos() async {
    final db = await database;
    final maps = await db.query('todos', orderBy: 'dateTime ASC');

    return List.generate(maps.length, (i) {
      return TodoModel.fromJson(maps[i]);
    });
  }

  // Delete a todo permanently
  static Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
