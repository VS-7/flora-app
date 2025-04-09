import '../interfaces/repository.dart';
import '../models/daily_receipt_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class DailyReceiptSyncService extends BaseSyncService<DailyReceipt> {
  DailyReceiptSyncService({
    required Repository<DailyReceipt> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'daily_receipts',
         entityType: 'daily_receipt',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(DailyReceipt entity) {
    final map = entity.toMap();
    // Add specific fields for Supabase, if needed
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  DailyReceipt supabaseDataToEntity(Map<String, dynamic> data) {
    return DailyReceipt.fromMap(data);
  }
}
