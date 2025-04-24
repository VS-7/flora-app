import '../../domain/interfaces/repository.dart';
import '../../domain/models/farm_activity_model.dart';
import '../database/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class FarmActivityRepository implements Repository<FarmActivity> {
  final AppDatabase _appDatabase;
  final String _tableName = 'farm_activities';

  FarmActivityRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase();

  @override
  Future<List<FarmActivity>> getAll() async {
    final db = await _appDatabase.database;
    final result = await db.query(_tableName);
    return result.map((e) => FarmActivity.fromMap(e)).toList();
  }

  @override
  Future<FarmActivity?> getById(String id) async {
    final db = await _appDatabase.database;
    final result = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    return FarmActivity.fromMap(result.first);
  }

  @override
  Future<String> insert(FarmActivity entity) async {
    final db = await _appDatabase.database;
    final id = entity.id.isEmpty ? const Uuid().v4() : entity.id;

    final activityWithId = FarmActivity(
      id: id,
      title: entity.title,
      description: entity.description,
      date: entity.date,
      type: entity.type,
      farmId: entity.farmId,
      talhaoId: entity.talhaoId,
      harvestId: entity.harvestId,
      employeeId: entity.employeeId,
      productIds: entity.productIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );

    await db.insert(_tableName, activityWithId.toMap());
    return id;
  }

  @override
  Future<void> update(FarmActivity entity) async {
    final db = await _appDatabase.database;
    await db.update(
      _tableName,
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FarmActivity>> getByFarmId(String farmId) async {
    final db = await _appDatabase.database;
    final result = await db.query(
      _tableName,
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );

    return result.map((e) => FarmActivity.fromMap(e)).toList();
  }

  Future<List<FarmActivity>> getByDate(DateTime date) async {
    final db = await _appDatabase.database;
    final dateString = date.toIso8601String().split('T')[0];

    final result = await db.rawQuery(
      "SELECT * FROM $_tableName WHERE date(date) = ?",
      [dateString],
    );

    return result.map((e) => FarmActivity.fromMap(e)).toList();
  }

  Future<List<FarmActivity>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _appDatabase.database;
    final startDateString = startDate.toIso8601String();
    final endDateString = endDate.toIso8601String();

    final result = await db.query(
      _tableName,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDateString, endDateString],
    );

    return result.map((e) => FarmActivity.fromMap(e)).toList();
  }

  Future<List<FarmActivity>> getByHarvestId(String harvestId) async {
    final db = await _appDatabase.database;
    final result = await db.query(
      _tableName,
      where: 'harvest_id = ?',
      whereArgs: [harvestId],
    );

    return result.map((e) => FarmActivity.fromMap(e)).toList();
  }

  Future<List<FarmActivity>> getByTalhaoId(String talhaoId) async {
    final db = await _appDatabase.database;
    final result = await db.query(
      _tableName,
      where: 'talhao_id = ?',
      whereArgs: [talhaoId],
    );

    return result.map((e) => FarmActivity.fromMap(e)).toList();
  }
}
