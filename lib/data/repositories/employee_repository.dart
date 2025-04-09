import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/employee_model.dart';
import '../database/app_database.dart';

class EmployeeRepository implements Repository<Employee> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Employee>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  @override
  Future<Employee?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Employee.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Employee entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'employees',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Employee entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'employees',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Employee>> getEmployeesByFarmId(String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  Future<List<Employee>> getEmployeesByRole(String role, String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'role = ? AND farm_id = ?',
      whereArgs: [role, farmId],
    );
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }
}
