import '../../domain/interfaces/repository.dart';
import '../../domain/models/auth_model.dart';
import '../../domain/models/farm_model.dart';
import '../../domain/models/employee_model.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/talhao_model.dart';
import '../../domain/models/harvest_model.dart';
import '../../domain/models/farm_activity_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/farm_repository.dart';
import '../repositories/employee_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/talhao_repository.dart';
import '../repositories/harvest_repository.dart';
import '../repositories/farm_activity_repository.dart';
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

  static Repository<Employee> createEmployeeRepository({
    bool syncAware = false,
  }) {
    final baseRepo = EmployeeRepository();
    if (!syncAware) return baseRepo;

    return SyncAwareRepository<Employee>(
      baseRepo,
      SyncStatusRepository(),
      'employee',
    );
  }

  static Repository<Product> createProductRepository({bool syncAware = false}) {
    final baseRepo = ProductRepository();
    if (!syncAware) return baseRepo;

    return SyncAwareRepository<Product>(
      baseRepo,
      SyncStatusRepository(),
      'product',
    );
  }

  static Repository<Talhao> createTalhaoRepository({bool syncAware = false}) {
    final baseRepo = TalhaoRepository();
    if (!syncAware) return baseRepo;

    return SyncAwareRepository<Talhao>(
      baseRepo,
      SyncStatusRepository(),
      'talhao',
    );
  }

  static Repository<Harvest> createHarvestRepository({bool syncAware = false}) {
    final baseRepo = HarvestRepository();
    if (!syncAware) return baseRepo;

    return SyncAwareRepository<Harvest>(
      baseRepo,
      SyncStatusRepository(),
      'harvest',
    );
  }

  static Repository<FarmActivity> createFarmActivityRepository({
    bool syncAware = false,
  }) {
    final baseRepo = FarmActivityRepository();
    if (!syncAware) return baseRepo;

    return SyncAwareRepository<FarmActivity>(
      baseRepo,
      SyncStatusRepository(),
      'farm_activity',
    );
  }
}
