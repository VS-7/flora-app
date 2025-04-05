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

    final pendingEntities = await _getPendingEntities();
    final client = SupabaseConfig.client;

    for (final entity in pendingEntities) {
      try {
        final existsRemotely = await _checkExistsInSupabase(entity.id);

        if (existsRemotely) {
          // Atualizar registro existente
          await client
              .from(tableName)
              .update(entityToSupabaseMap(entity))
              .eq('id', entity.id);
        } else {
          // Inserir novo registro
          await client.from(tableName).insert(entityToSupabaseMap(entity));
        }

        // Marcar como sincronizado
        await syncStatusRepository.markAsSynced(entity.id, entityType);
      } catch (e) {
        // Em caso de erro, mantém o status como pendente para tentar novamente depois
        print('Erro ao sincronizar entidade ${entity.id}: $e');
      }
    }
  }

  @override
  Future<void> syncDown() async {
    if (!connectivityHelper.isConnected) {
      return;
    }

    final lastSyncTime = await syncStatusRepository.getLastSyncTime(entityType);
    final client = SupabaseConfig.client;

    PostgrestFilterBuilder query = client.from(tableName).select();

    if (lastSyncTime != null) {
      // Se já houve sincronização, busca apenas registros mais recentes
      query = query.gte('updated_at', lastSyncTime.toIso8601String());
    }

    final response = await query;

    List<dynamic> remoteData = response;

    final remoteEntities =
        remoteData
            .map((data) => supabaseDataToEntity(data as Map<String, dynamic>))
            .toList();

    for (final entity in remoteEntities) {
      // Busca a entidade local
      final localEntity = await localRepository.getById(entity.id);

      if (localEntity == null) {
        // Se não existe localmente, insere
        await localRepository.insert(entity);
        await syncStatusRepository.markAsSynced(entity.id, entityType);
      } else {
        // Verificar se há conflito com versão local
        final syncStatus = await syncStatusRepository.getByEntityId(
          entity.id,
          entityType,
        );

        if (syncStatus == null || syncStatus.state != SyncState.pending) {
          // Se não estiver pendente de sincronização, atualiza com a versão remota
          await localRepository.update(entity);
          await syncStatusRepository.markAsSynced(entity.id, entityType);
        } else {
          // Conflito: versão local e remota foram alteradas
          // Por padrão, mantenha a versão local e marque como pendente
          await syncStatusRepository.markAsPending(entity.id, entityType);
        }
      }
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

    return response != null && response.length > 0;
  }
}
