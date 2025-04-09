import 'package:sqflite/sqflite.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/product_use_model.dart';
import '../database/app_database.dart';

class ProductUseRepository implements Repository<ProductUse> {
  final AppDatabase _appDatabase = AppDatabase();

  @override
  Future<List<ProductUse>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('product_uses');
    return List.generate(maps.length, (i) => ProductUse.fromMap(maps[i]));
  }

  @override
  Future<ProductUse?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'product_uses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ProductUse.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> insert(ProductUse entity) async {
    final db = await _appDatabase.database;
    await db.insert(
      'product_uses',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(ProductUse entity) async {
    final db = await _appDatabase.database;
    await db.update(
      'product_uses',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('product_uses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ProductUse>> getProductUsesByProductId(String productId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'product_uses',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return List.generate(maps.length, (i) => ProductUse.fromMap(maps[i]));
  }

  Future<List<ProductUse>> getProductUsesByHarvestId(String harvestId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'product_uses',
      where: 'harvest_id = ?',
      whereArgs: [harvestId],
    );
    return List.generate(maps.length, (i) => ProductUse.fromMap(maps[i]));
  }

  Future<List<ProductUse>> getProductUsesByFarmId(String farmId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'product_uses',
      where: 'farm_id = ?',
      whereArgs: [farmId],
    );
    return List.generate(maps.length, (i) => ProductUse.fromMap(maps[i]));
  }
}
