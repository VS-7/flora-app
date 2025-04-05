import '../interfaces/repository.dart';
import '../models/payment_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class PaymentSyncService extends BaseSyncService<Payment> {
  PaymentSyncService({
    required Repository<Payment> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'payments',
         entityType: 'payment',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(Payment entity) {
    final map = entity.toMap();
    // Adicionar campos específicos para o Supabase, se necessário
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  Payment supabaseDataToEntity(Map<String, dynamic> data) {
    return Payment.fromMap(data);
  }
}
