import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/product_model.dart';
import '../database/app_database.dart';

class ProductRepository implements Repository<Product> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<Product>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  @override
  Future<Product?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(Product entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'products',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(Product entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'products',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getProductsByFarmId(String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getProductsByType(String type, String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'type = ? AND farm_id = ?',
      whereArgs: [type, farmId],
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }
}
