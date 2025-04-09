import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/lot_model.dart';
import '../database/app_database.dart';

class LotRepository implements Repository<Lot> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Lot>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('lots');
    return List.generate(maps.length, (i) => Lot.fromMap(maps[i]));
  }

  @override
  Future<Lot?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lots',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Lot.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Lot entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'lots',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Lot entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'lots',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('lots', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Lot>> getLotsByFarmId(String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'lots',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return List.generate(maps.length, (i) => Lot.fromMap(maps[i]));
  }
}
