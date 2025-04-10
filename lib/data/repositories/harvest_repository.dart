import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/harvest_model.dart';
import '../database/app_database.dart';

class HarvestRepository implements Repository<Harvest> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Harvest>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('harvests');
    return List.generate(maps.length, (i) => Harvest.fromMap(maps[i]));
  }

  @override
  Future<Harvest?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'harvests',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Harvest.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Harvest entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'harvests',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Harvest entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'harvests',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('harvests', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Harvest>> getHarvestsByFarmId(String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'harvests',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return List.generate(maps.length, (i) => Harvest.fromMap(maps[i]));
  }

  Future<List<Harvest>> getHarvestsByTalhaoId(String talhaoId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'harvests',
      where: 'talhao_id = ?',
      whereArgs: [talhaoId],
    );
    return List.generate(maps.length, (i) => Harvest.fromMap(maps[i]));
  }

  Future<List<Harvest>> getHarvestsByDateRange(
    DateTime startDate,
    DateTime endDate,
    String farmId,
  ) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'harvests',
      where: 'start_date BETWEEN ? AND ? AND farm_id = ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
        farmId,
      ],
    );
    return List.generate(maps.length, (i) => Harvest.fromMap(maps[i]));
  }
}
