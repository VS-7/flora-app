import '../interfaces/repository.dart';
import '../models/lot_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class LotSyncService extends BaseSyncService<Lot> {
  LotSyncService({
    required Repository<Lot> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'lots',
         entityType: 'lot',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(Lot entity) {
    final map = entity.toMap();
    // Add specific fields for Supabase, if needed
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  Lot supabaseDataToEntity(Map<String, dynamic> data) {
    return Lot.fromMap(data);
  }
}
