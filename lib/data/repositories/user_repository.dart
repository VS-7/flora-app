import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/user_model.dart';
import '../database/app_database.dart';

class UserRepository implements Repository<User> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<User>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  @override
  Future<User?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(User entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'users',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(User entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'users',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
