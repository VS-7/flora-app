import '../interfaces/repository.dart';
import '../models/farm_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class FarmSyncService extends BaseSyncService<Farm> {
  FarmSyncService({
    required Repository<Farm> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'farms',
         entityType: 'farm',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(Farm entity) {
    final map = entity.toMap();
    // Adicionar campos específicos para o Supabase, se necessário
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  Farm supabaseDataToEntity(Map<String, dynamic> data) {
    return Farm.fromMap(data);
  }
}
