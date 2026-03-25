import "package:sqflite/sqflite.dart";
import "package:jbl_pills_reminder_app/src/core/database/sqlite_helper.dart";

class LocalDbRepository {
  static const String tablePreferences = "app_preferences";
  static const String tableReminders = "reminders";
  static const String tableRemindersDone = "reminders_done";

  // --- App Preferences ---
  Future<void> savePreference(String key, String value) async {
    final db = await SqliteHelper.database;
    await db.insert(
      tablePreferences,
      {"key": key, "value": value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearPreferences() async {
    final db = await SqliteHelper.database;
    await db.delete(tablePreferences);
  }

  Future<String?> getPreference(String key) async {
    final db = await SqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tablePreferences,
      where: "key = ?",
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first["value"] as String?;
    }
    return null;
  }

  Future<void> deletePreference(String key) async {
    final db = await SqliteHelper.database;
    await db.delete(
      tablePreferences,
      where: "key = ?",
      whereArgs: [key],
    );
  }


  // --- Reminders ---
  Future<void> saveReminder(String id, String jsonData) async {
    final db = await SqliteHelper.database;
    await db.insert(
      tableReminders,
      {"id": id, "data": jsonData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getReminder(String id) async {
    final db = await SqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableReminders,
      where: "id = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first["data"] as String?;
    }
    return null;
  }

  Future<Map<String, String>> getAllReminders() async {
    final db = await SqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(tableReminders);
    return { for (var map in maps) map["id"] as String : map["data"] as String };
  }

  Future<void> deleteReminder(String id) async {
    final db = await SqliteHelper.database;
    await db.delete(
      tableReminders,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> clearReminders() async {
    final db = await SqliteHelper.database;
    await db.delete(tableReminders);
  }

  // --- Reminders Done ---
  Future<void> saveReminderDone(String id, String jsonData) async {
    final db = await SqliteHelper.database;
    await db.insert(
      tableRemindersDone,
      {"id": id, "data": jsonData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAllRemindersDone() async {
    final db = await SqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(tableRemindersDone);
    return { for (var map in maps) map["id"] as String : map["data"] as String };
  }

  Future<void> deleteReminderDone(String id) async {
    final db = await SqliteHelper.database;
    await db.delete(
      tableRemindersDone,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
