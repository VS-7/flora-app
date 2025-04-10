import '../../data/factories/repository_factory.dart';
import '../../data/repositories/farm_repository.dart';
import '../../data/repositories/employee_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/talhao_repository.dart';
import '../../data/repositories/harvest_repository.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../domain/interfaces/service.dart';
import '../../domain/interfaces/sync_service.dart';
import '../../domain/models/auth_model.dart';
import '../../domain/models/farm_model.dart';
import '../../domain/models/employee_model.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/talhao_model.dart';
import '../../domain/models/harvest_model.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/farm_service.dart';
import '../../domain/services/farm_sync_service.dart';
import '../../domain/services/employee_service.dart';
import '../../domain/services/employee_sync_service.dart';
import '../../domain/services/product_service.dart';
import '../../domain/services/product_sync_service.dart';
import '../../domain/services/talhao_service.dart';
import '../../domain/services/talhao_sync_service.dart';
import '../../domain/services/harvest_service.dart';
import '../../domain/services/harvest_sync_service.dart';
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

  static Service<Product> createProductService() {
    final repository = RepositoryFactory.createProductRepository(
      syncAware: true,
    );
    return ProductService(repository);
  }

  static Service<Talhao> createTalhaoService() {
    final repository = RepositoryFactory.createTalhaoRepository(
      syncAware: true,
    );
    return TalhaoService(repository);
  }

  static Service<Harvest> createHarvestService() {
    final repository = RepositoryFactory.createHarvestRepository(
      syncAware: true,
    );
    return HarvestService(repository);
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

  static SyncService<Product> createProductSyncService() {
    final repository =
        RepositoryFactory.createProductRepository() as ProductRepository;
    final syncStatusRepository = SyncStatusRepository();
    final connectivityHelper = ConnectivityHelper();

    return ProductSyncService(
      localRepository: repository,
      syncStatusRepository: syncStatusRepository,
      connectivityHelper: connectivityHelper,
    );
  }

  static SyncService<Talhao> createTalhaoSyncService() {
    final repository =
        RepositoryFactory.createTalhaoRepository() as TalhaoRepository;
    final syncStatusRepository = SyncStatusRepository();
    final connectivityHelper = ConnectivityHelper();

    return TalhaoSyncService(
      localRepository: repository,
      syncStatusRepository: syncStatusRepository,
      connectivityHelper: connectivityHelper,
    );
  }

  static SyncService<Harvest> createHarvestSyncService() {
    final repository =
        RepositoryFactory.createHarvestRepository() as HarvestRepository;
    final syncStatusRepository = SyncStatusRepository();
    final connectivityHelper = ConnectivityHelper();

    return HarvestSyncService(
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
      productSyncService: createProductSyncService(),
      talhaoSyncService: createTalhaoSyncService(),
      harvestSyncService: createHarvestSyncService(),
    );
  }
}
