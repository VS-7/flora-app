import '../interfaces/repository.dart';
import '../models/product_use_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class ProductUseSyncService extends BaseSyncService<ProductUse> {
  ProductUseSyncService({
    required Repository<ProductUse> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'product_uses',
         entityType: 'product_use',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(ProductUse entity) {
    final map = entity.toMap();
    // Add specific fields for Supabase, if needed
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  ProductUse supabaseDataToEntity(Map<String, dynamic> data) {
    return ProductUse.fromMap(data);
  }
}
