import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/talhao_model.dart';
import '../database/app_database.dart';

class TalhaoRepository implements Repository<Talhao> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Talhao>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('talhoes');
    return List.generate(maps.length, (i) => Talhao.fromMap(maps[i]));
  }

  @override
  Future<Talhao?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'talhoes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Talhao.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Talhao entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'talhoes',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Talhao entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'talhoes',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('talhoes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Talhao>> getTalhoesByFarmId(String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'talhoes',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return List.generate(maps.length, (i) => Talhao.fromMap(maps[i]));
  }
}
