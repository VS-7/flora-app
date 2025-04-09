import '../interfaces/repository.dart';
import '../models/employee_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class EmployeeSyncService extends BaseSyncService<Employee> {
  EmployeeSyncService({
    required Repository<Employee> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'employees',
         entityType: 'employee',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(Employee entity) {
    final map = entity.toMap();
    // Add specific fields for Supabase, if needed
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  Employee supabaseDataToEntity(Map<String, dynamic> data) {
    return Employee.fromMap(data);
  }
}
