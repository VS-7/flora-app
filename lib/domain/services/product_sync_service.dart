import '../interfaces/repository.dart';
import '../models/product_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class ProductSyncService extends BaseSyncService<Product> {
  ProductSyncService({
    required Repository<Product> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'products',
         entityType: 'product',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(Product entity) {
    final map = entity.toMap();
    // Add specific fields for Supabase, if needed
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  Product supabaseDataToEntity(Map<String, dynamic> data) {
    return Product.fromMap(data);
  }
}
