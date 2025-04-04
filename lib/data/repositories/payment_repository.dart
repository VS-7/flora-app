import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/payment_model.dart';
import '../database/app_database.dart';

class PaymentRepository implements Repository<Payment> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Payment>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('payments');
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  @override
  Future<Payment?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Payment.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Payment entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'payments',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Payment entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'payments',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  // Métodos específicos para pagamentos
  Future<List<Payment>> getPaymentsByCollaborator(String collaboratorId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'collaborator_id = ?',
      whereArgs: [collaboratorId],
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  Future<double> getTotalPaymentsByCollaborator(String collaboratorId) async {
    final db = await _appDatabase.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM payments WHERE collaborator_id = ?',
      [collaboratorId],
    );

    if (result.isNotEmpty && result[0]['total'] != null) {
      return result[0]['total'] as double;
    }
    return 0.0;
  }

  Future<List<Payment>> getPaymentsInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _appDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }
}
