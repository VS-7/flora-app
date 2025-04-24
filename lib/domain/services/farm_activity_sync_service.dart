import '../../domain/services/base_sync_service.dart';
import '../../domain/models/farm_activity_model.dart';
import '../../data/repositories/farm_activity_repository.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';

class FarmActivitySyncService extends BaseSyncService<FarmActivity> {
  FarmActivitySyncService({
    required FarmActivityRepository localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'farm_activities',
         entityType: 'FarmActivity',
       );

  @override
  FarmActivity supabaseDataToEntity(Map<String, dynamic> data) {
    return FarmActivity.fromMap(data);
  }

  @override
  Map<String, dynamic> entityToSupabaseMap(FarmActivity entity) {
    final map = entity.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }
}
