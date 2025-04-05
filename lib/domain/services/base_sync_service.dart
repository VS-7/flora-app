import 'package:supabase_flutter/supabase_flutter.dart';
import '../interfaces/entity.dart';
import '../interfaces/repository.dart';
import '../interfaces/sync_service.dart';
import '../models/sync_status.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../data/database/supabase_config.dart';
import '../../utils/connectivity_helper.dart';

abstract class BaseSyncService<T extends Entity> implements SyncService<T> {
  final Repository<T> localRepository;
  final SyncStatusRepository syncStatusRepository;
  final ConnectivityHelper connectivityHelper;
  final String tableName;
  final String entityType;

  BaseSyncService({
    required this.localRepository,
    required this.syncStatusRepository,
    required this.connectivityHelper,
    required this.tableName,
    required this.entityType,
  });

  // Método para converter entidade para Map para o Supabase
  Map<String, dynamic> entityToSupabaseMap(T entity);

  // Método para converter dados do Supabase para entidade
  T supabaseDataToEntity(Map<String, dynamic> data);

  @override
  Future<void> syncUp() async {
    if (!connectivityHelper.isConnected) {
      return;
    }

    // Verificar se há um usuário autenticado
    final session = SupabaseConfig.client.auth.currentSession;
    if (session == null) {
      print(
        'Sincronização para cima não foi executada: usuário não autenticado',
      );
      return;
    }

    final pendingEntities = await _getPendingEntities();

    for (final entity in pendingEntities) {
      try {
        final existsOnServer = await _checkExistsInSupabase(entity.id);
        final client = SupabaseConfig.client;
        final Map<String, dynamic> data = entityToSupabaseMap(entity);

        if (existsOnServer) {
          // Update
          await client.from(tableName).update(data).eq('id', entity.id);
        } else {
          // Insert
          await client.from(tableName).insert(data);
        }

        await markAsSynced(entity);
      } catch (e) {
        print('Erro ao sincronizar entidade ${entity.id}: $e');
      }
    }
  }

  @override
  Future<void> syncDown() async {
    if (!connectivityHelper.isConnected) {
      return;
    }

    // Verificar se há um usuário autenticado
    final session = SupabaseConfig.client.auth.currentSession;
    if (session == null) {
      print(
        'Sincronização para baixo não foi executada: usuário não autenticado',
      );
      return;
    }

    try {
      final lastSyncTime = await getLastSyncTime();
      final client = SupabaseConfig.client;
      final query = client.from(tableName).select();

      if (lastSyncTime != null) {
        query.gt('updated_at', lastSyncTime.toIso8601String());
      }

      final response = await query;
      if (response != null) {
        for (final item in response) {
          final entity = supabaseDataToEntity(item);
          await localRepository.insert(entity);
          await markAsSynced(entity);
        }
      }

      await syncStatusRepository.updateLastSyncTime(entityType, DateTime.now());
    } catch (e) {
      print('Erro ao sincronizar dados do servidor: $e');
    }
  }

  @override
  Future<bool> hasPendingSync() async {
    final pendingEntities = await syncStatusRepository.getAllPendingSync();
    return pendingEntities.any((status) => status.entityType == entityType);
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return syncStatusRepository.getLastSyncTime(entityType);
  }

  @override
  Future<void> markAsSynced(T entity) async {
    await syncStatusRepository.markAsSynced(entity.id, entityType);
  }

  @override
  Future<void> autoSync() async {
    if (connectivityHelper.isConnected) {
      await syncUp();
      await syncDown();
    }
  }

  // Métodos auxiliares
  Future<List<T>> _getPendingEntities() async {
    final pendingStatuses = await syncStatusRepository.getAllPendingSync();
    final List<T> pendingEntities = [];

    for (final status in pendingStatuses) {
      if (status.entityType == entityType) {
        final entity = await localRepository.getById(status.entityId);
        if (entity != null) {
          pendingEntities.add(entity);
        }
      }
    }

    return pendingEntities;
  }

  Future<bool> _checkExistsInSupabase(String id) async {
    final client = SupabaseConfig.client;
    final response = await client
        .from(tableName)
        .select('id')
        .eq('id', id)
        .limit(1);

    return response != null && response.isNotEmpty;
  }
}
