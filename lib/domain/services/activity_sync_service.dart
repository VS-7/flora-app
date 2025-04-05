import '../interfaces/repository.dart';
import '../models/activity_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class ActivitySyncService extends BaseSyncService<Activity> {
  ActivitySyncService({
    required Repository<Activity> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'activities',
         entityType: 'activity',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(Activity entity) {
    final map = entity.toMap();
    // Adicionar campos específicos para o Supabase, se necessário
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  Activity supabaseDataToEntity(Map<String, dynamic> data) {
    return Activity.fromMap(data);
  }
}
