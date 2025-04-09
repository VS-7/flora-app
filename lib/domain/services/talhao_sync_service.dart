import '../interfaces/repository.dart';
import '../models/talhao_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class TalhaoSyncService extends BaseSyncService<Talhao> {
  TalhaoSyncService({
    required Repository<Talhao> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'lots',
         entityType: 'talhao',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(Talhao entity) {
    final map = entity.toMap();
    // Add specific fields for Supabase, if needed
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  Talhao supabaseDataToEntity(Map<String, dynamic> data) {
    return Talhao.fromMap(data);
  }
}
