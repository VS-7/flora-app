import '../interfaces/repository.dart';
import '../models/employee_production_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class EmployeeProductionSyncService
    extends BaseSyncService<EmployeeProduction> {
  EmployeeProductionSyncService({
    required Repository<EmployeeProduction> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'employee_productions',
         entityType: 'employee_production',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(EmployeeProduction entity) {
    final map = entity.toMap();
    // Add specific fields for Supabase, if needed
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  EmployeeProduction supabaseDataToEntity(Map<String, dynamic> data) {
    return EmployeeProduction.fromMap(data);
  }
}
