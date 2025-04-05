import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/auth_model.dart';
import '../database/app_database.dart';

class AuthRepository implements Repository<Auth> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Auth>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('auth');
    return List.generate(maps.length, (i) => Auth.fromMap(maps[i]));
  }

  @override
  Future<Auth?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'auth',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Auth.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Auth entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'auth',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Auth entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'auth',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('auth', where: 'id = ?', whereArgs: [id]);
  }

  Future<Auth?> getLastAuthenticated() async {
    final all = await getAll();
    if (all.isEmpty) return null;
    return all.first;
  }
}
