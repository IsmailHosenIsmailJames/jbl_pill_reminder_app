import "package:sqflite/sqflite.dart";
import "package:path/path.dart";

class SqliteHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "pill_reminder_app.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE app_preferences(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    """);

    await db.execute("""
      CREATE TABLE reminders(
        id TEXT PRIMARY KEY,
        data TEXT
      )
    """);

    await db.execute("""
      CREATE TABLE reminders_done(
        id TEXT PRIMARY KEY,
        data TEXT
      )
    """);
  }
}
