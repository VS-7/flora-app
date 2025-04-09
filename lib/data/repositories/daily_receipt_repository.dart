import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/daily_receipt_model.dart';
import '../database/app_database.dart';

class DailyReceiptRepository implements Repository<DailyReceipt> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<DailyReceipt>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('daily_receipts');
    return List.generate(maps.length, (i) => DailyReceipt.fromMap(maps[i]));
  }

  @override
  Future<DailyReceipt?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_receipts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DailyReceipt.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(DailyReceipt entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'daily_receipts',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(DailyReceipt entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'daily_receipts',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('daily_receipts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DailyReceipt>> getReceiptsByEmployeeId(String employeeId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_receipts',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
    );
    return List.generate(maps.length, (i) => DailyReceipt.fromMap(maps[i]));
  }

  Future<List<DailyReceipt>> getReceiptsByHarvestId(String harvestId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_receipts',
      where: 'harvest_id = ?',
      whereArgs: [harvestId],
    );
    return List.generate(maps.length, (i) => DailyReceipt.fromMap(maps[i]));
  }

  Future<List<DailyReceipt>> getReceiptsByTaskId(String taskId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_receipts',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
    return List.generate(maps.length, (i) => DailyReceipt.fromMap(maps[i]));
  }

  Future<List<DailyReceipt>> getReceiptsByFarmId(String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_receipts',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return List.generate(maps.length, (i) => DailyReceipt.fromMap(maps[i]));
  }

  Future<List<DailyReceipt>> getReceiptsByPrintStatus(
    String printStatus,
    String farmId,
  ) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_receipts',
      where: 'print_status = ? AND farm_id = ?',
      whereArgs: [printStatus, farmId],
    );
    return List.generate(maps.length, (i) => DailyReceipt.fromMap(maps[i]));
  }
}
