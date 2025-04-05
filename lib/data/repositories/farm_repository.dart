import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/farm_model.dart';
import '../database/app_database.dart';

class FarmRepository implements Repository<Farm> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Farm>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('farms');
    return List.generate(maps.length, (i) => Farm.fromMap(maps[i]));
  }

  @override
  Future<Farm?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'farms',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Farm.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Farm entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'farms',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Farm entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'farms',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('farms', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Farm>> getFarmsByUserId(String userId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'farms',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Farm.fromMap(maps[i]));
  }
}
