import '../../data/factories/repository_factory.dart';
import '../../data/repositories/farm_repository.dart';
import '../../data/repositories/employee_repository.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../domain/interfaces/service.dart';
import '../../domain/interfaces/sync_service.dart';
import '../../domain/models/auth_model.dart';
import '../../domain/models/farm_model.dart';
import '../../domain/models/employee_model.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/farm_service.dart';
import '../../domain/services/farm_sync_service.dart';
import '../../domain/services/employee_service.dart';
import '../../domain/services/employee_sync_service.dart';
import '../../domain/services/sync_manager.dart';
import '../../utils/connectivity_helper.dart';

class ServiceFactory {
  static Service<Auth> createAuthService() {
    final repository = RepositoryFactory.createAuthRepository();
    return AuthService(repository);
  }

  static Service<Farm> createFarmService() {
    final repository = RepositoryFactory.createFarmRepository(syncAware: true);
    return FarmService(repository);
  }

  static Service<Employee> createEmployeeService() {
    final repository = RepositoryFactory.createEmployeeRepository(
      syncAware: true,
    );
    return EmployeeService(repository);
  }

  static SyncService<Farm> createFarmSyncService() {
    final repository =
        RepositoryFactory.createFarmRepository() as FarmRepository;
    final syncStatusRepository = SyncStatusRepository();
    final connectivityHelper = ConnectivityHelper();

    return FarmSyncService(
      localRepository: repository,
      syncStatusRepository: syncStatusRepository,
      connectivityHelper: connectivityHelper,
    );
  }

  static SyncService<Employee> createEmployeeSyncService() {
    final repository =
        RepositoryFactory.createEmployeeRepository() as EmployeeRepository;
    final syncStatusRepository = SyncStatusRepository();
    final connectivityHelper = ConnectivityHelper();

    return EmployeeSyncService(
      localRepository: repository,
      syncStatusRepository: syncStatusRepository,
      connectivityHelper: connectivityHelper,
    );
  }

  // Método para criar o Sync Manager
  static SyncManager createSyncManager() {
    return SyncManager(
      connectivityHelper: ConnectivityHelper(),
      farmSyncService: createFarmSyncService(),
      employeeSyncService: createEmployeeSyncService(),
    );
  }
}
