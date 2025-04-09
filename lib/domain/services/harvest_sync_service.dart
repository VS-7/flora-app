import '../interfaces/repository.dart';
import '../models/harvest_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class HarvestSyncService extends BaseSyncService<Harvest> {
  HarvestSyncService({
    required Repository<Harvest> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'harvests',
         entityType: 'harvest',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(Harvest entity) {
    final map = entity.toMap();
    // Add specific fields for Supabase, if needed
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  Harvest supabaseDataToEntity(Map<String, dynamic> data) {
    return Harvest.fromMap(data);
  }
}
