import '../interfaces/repository.dart';
import '../models/user_model.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../utils/connectivity_helper.dart';
import 'base_sync_service.dart';

class UserSyncService extends BaseSyncService<User> {
  UserSyncService({
    required Repository<User> localRepository,
    required SyncStatusRepository syncStatusRepository,
    required ConnectivityHelper connectivityHelper,
  }) : super(
         localRepository: localRepository,
         syncStatusRepository: syncStatusRepository,
         connectivityHelper: connectivityHelper,
         tableName: 'users',
         entityType: 'user',
       );

  @override
  Map<String, dynamic> entityToSupabaseMap(User entity) {
    final map = entity.toMap();
    // Adicionar campos específicos para o Supabase, se necessário
    map['updated_at'] = DateTime.now().toIso8601String();
    return map;
  }

  @override
  User supabaseDataToEntity(Map<String, dynamic> data) {
    return User.fromMap(data);
  }
}
