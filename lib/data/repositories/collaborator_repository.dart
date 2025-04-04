import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/collaborator_model.dart';
import '../database/app_database.dart';

class CollaboratorRepository implements Repository<Collaborator> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Collaborator>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('collaborators');
    return List.generate(maps.length, (i) => Collaborator.fromMap(maps[i]));
  }

  @override
  Future<Collaborator?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'collaborators',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Collaborator.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Collaborator entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'collaborators',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Collaborator entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'collaborators',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('collaborators', where: 'id = ?', whereArgs: [id]);
  }
}
