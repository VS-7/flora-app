import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/task_model.dart';
import '../database/app_database.dart';

class TaskRepository implements Repository<Task> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Task>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  @override
  Future<Task?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Task entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'tasks',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Task entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'tasks',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getTasksByFarmId(String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
    String farmId,
  ) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'date BETWEEN ? AND ? AND farm_id = ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
        farmId,
      ],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByEmployeeId(String employeeId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT * FROM tasks 
      WHERE assigned_employees LIKE ?
      ''',
      ['%"$employeeId"%'],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }
}
