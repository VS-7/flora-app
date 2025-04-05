import '../interfaces/repository.dart';
import '../models/collaborator_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class CollaboratorSyncService extends BaseSyncService<Collaborator> {
  CollaboratorSyncService({
    required Repository<Collaborator> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'collaborators',
         entityType: 'collaborator',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(Collaborator entity) {
    final map = entity.toMap();
    // Adicionar campos específicos para o Supabase, se necessário
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  Collaborator supabaseDataToEntity(Map<String, dynamic> data) {
    return Collaborator.fromMap(data);
  }
}
