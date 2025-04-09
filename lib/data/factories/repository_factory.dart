import '../../domain/interfaces/repository.dart';
import '../../domain/models/auth_model.dart';
import '../../domain/models/farm_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/farm_repository.dart';
import '../repositories/sync_status_repository.dart';
import '../repositories/sync_aware_repository.dart';

class RepositoryFactory {
  static Repository<Auth> createAuthRepository() {
    return AuthRepository();
  }

  static Repository<Farm> createFarmRepository({bool syncAware = false}) {
    final baseRepo = FarmRepository();
    if (!syncAware) return baseRepo;

    return SyncAwareRepository<Farm>(baseRepo, SyncStatusRepository(), 'farm');
  }
}
