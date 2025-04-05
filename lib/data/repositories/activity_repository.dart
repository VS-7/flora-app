import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/activity_model.dart';
import '../database/app_database.dart';

class ActivityRepository implements Repository<Activity> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Activity>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('activities');
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  @override
  Future<Activity?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Activity.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Activity entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'activities',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Activity entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'activities',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos específicos para atividades
  Future<List<Activity>> getActivitiesByType(ActivityType type) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'type = ?',
      whereArgs: [type.name],
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<List<Activity>> getActivitiesByDate(DateTime date) async {
    final db = await _appDatabase.database;
    final dateStr = date.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      "SELECT * FROM activities WHERE date LIKE '$dateStr%'",
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  Future<List<Activity>> getActivitiesInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }
}
