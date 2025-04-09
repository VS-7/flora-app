import '../interfaces/repository.dart';
import '../models/task_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class TaskSyncService extends BaseSyncService<Task> {
  TaskSyncService({
    required Repository<Task> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'tasks',
         entityType: 'task',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(Task entity) {
    final map = entity.toMap();
    // Add specific fields for Supabase, if needed
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  Task supabaseDataToEntity(Map<String, dynamic> data) {
    return Task.fromMap(data);
  }
}
