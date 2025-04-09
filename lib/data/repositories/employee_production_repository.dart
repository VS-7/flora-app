import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/employee_production_model.dart';
import '../database/app_database.dart';

class EmployeeProductionRepository implements Repository<EmployeeProduction> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<EmployeeProduction>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employee_productions',
    );
    return List.generate(
      maps.length,
      (i) => EmployeeProduction.fromMap(maps[i]),
    );
  }

  @override
  Future<EmployeeProduction?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employee_productions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return EmployeeProduction.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(EmployeeProduction entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'employee_productions',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(EmployeeProduction entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'employee_productions',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('employee_productions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<EmployeeProduction>> getProductionsByEmployeeId(
    String employeeId,
  ) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employee_productions',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
    );
    return List.generate(
      maps.length,
      (i) => EmployeeProduction.fromMap(maps[i]),
    );
  }

  Future<List<EmployeeProduction>> getProductionsByHarvestId(
    String harvestId,
  ) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employee_productions',
      where: 'harvest_id = ?',
      whereArgs: [harvestId],
    );
    return List.generate(
      maps.length,
      (i) => EmployeeProduction.fromMap(maps[i]),
    );
  }

  Future<List<EmployeeProduction>> getProductionsByFarmId(String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employee_productions',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return List.generate(
      maps.length,
      (i) => EmployeeProduction.fromMap(maps[i]),
    );
  }

  Future<List<EmployeeProduction>> getProductionsByDateRange(
    DateTime startDate,
    DateTime endDate,
    String farmId,
  ) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employee_productions',
      where: 'date BETWEEN ? AND ? AND farm_id = ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
        farmId,
      ],
    );
    return List.generate(
      maps.length,
      (i) => EmployeeProduction.fromMap(maps[i]),
    );
  }
}
