import 'package:sqflite/sqflite.dart';
import '../../domain/models/sync_status.dart';
import '../database/app_database.dart';

class SyncStatusRepository {
  final AppDatabase _appDatabase = AppDatabase();

  Future<List<SyncStatus>> getAllPendingSync() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_status',
      where: 'state = ?',
      whereArgs: [SyncState.pending.name],
    );
    return List.generate(maps.length, (i) => SyncStatus.fromMap(maps[i]));
  }

  Future<SyncStatus?> getByEntityId(String entityId, String entityType) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_status',
      where: 'entity_id = ? AND entity_type = ?',
      whereArgs: [entityId, entityType],
    );

    if (maps.isNotEmpty) {
      return SyncStatus.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertOrUpdate(SyncStatus syncStatus) async {
    final db = await _appDatabase.database;
    await db.insert(
      'sync_status',
      syncStatus.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String entityId, String entityType) async {
    final db = await _appDatabase.database;
    await db.delete(
      'sync_status',
      where: 'entity_id = ? AND entity_type = ?',
      whereArgs: [entityId, entityType],
    );
  }

  Future<void> markAsSynced(String entityId, String entityType) async {
    final syncStatus = await getByEntityId(entityId, entityType);
    if (syncStatus != null) {
      final updated = syncStatus.copyWith(
        state: SyncState.synced,
        lastSyncTime: DateTime.now(),
      );
      await insertOrUpdate(updated);
    }
  }

  Future<void> markAsPending(String entityId, String entityType) async {
    final syncStatus = await getByEntityId(entityId, entityType);
    final now = DateTime.now();

    if (syncStatus != null) {
      final updated = syncStatus.copyWith(
        state: SyncState.pending,
        lastLocalUpdate: now,
        version: syncStatus.version + 1,
      );
      await insertOrUpdate(updated);
    } else {
      // Criar um novo registro de status se não existir
      final newStatus = SyncStatus(
        entityId: entityId,
        entityType: entityType,
        state: SyncState.pending,
        lastSyncTime: DateTime.fromMillisecondsSinceEpoch(0),
        lastLocalUpdate: now,
        version: 1,
      );
      await insertOrUpdate(newStatus);
    }
  }

  Future<List<SyncStatus>> getByEntityType(String entityType) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_status',
      where: 'entity_type = ?',
      whereArgs: [entityType],
    );
    return List.generate(maps.length, (i) => SyncStatus.fromMap(maps[i]));
  }

  Future<DateTime?> getLastSyncTime(String entityType) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT MAX(last_sync_time) as max_sync_time
      FROM sync_status
      WHERE entity_type = ?
      ''',
      [entityType],
    );

    if (result.isNotEmpty && result.first['max_sync_time'] != null) {
      return DateTime.parse(result.first['max_sync_time'] as String);
    }
    return null;
  }
}
