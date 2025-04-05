import '../../data/factories/repository_factory.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/collaborator_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/sync_status_repository.dart';
import '../../domain/interfaces/service.dart';
import '../../domain/interfaces/sync_service.dart';
import '../../domain/models/activity_model.dart';
import '../../domain/models/auth_model.dart';
import '../../domain/models/collaborator_model.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/services/activity_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/collaborator_service.dart';
import '../../domain/services/payment_service.dart';
import '../../domain/services/user_service.dart';
import '../../domain/services/activity_sync_service.dart';
import '../../domain/services/collaborator_sync_service.dart';
import '../../domain/services/payment_sync_service.dart';
import '../../domain/services/user_sync_service.dart';
import '../../domain/services/sync_manager.dart';
import '../../utils/connectivity_helper.dart';

class ServiceFactory {
  static Service<User> createUserService() {
    final repository = RepositoryFactory.createUserRepository(syncAware: true);
    return UserService(repository);
  }

  static Service<Activity> createActivityService() {
    final repository = RepositoryFactory.createActivityRepository(
      syncAware: true,
    );
    return ActivityService(repository);
  }

  static Service<Collaborator> createCollaboratorService() {
    final repository = RepositoryFactory.createCollaboratorRepository(
      syncAware: true,
    );
    return CollaboratorService(repository);
  }

  static Service<Payment> createPaymentService() {
    final repository = RepositoryFactory.createPaymentRepository(
      syncAware: true,
    );
    return PaymentService(repository);
  }

  static Service<Auth> createAuthService() {
    final repository = RepositoryFactory.createAuthRepository();
    return AuthService(repository);
  }

  // Métodos para criar serviços de sincronização
  static SyncService<Activity> createActivitySyncService() {
    final repository =
        RepositoryFactory.createActivityRepository() as ActivityRepository;
    final syncStatusRepository = SyncStatusRepository();
    final connectivityHelper = ConnectivityHelper();

    return ActivitySyncService(
      localRepository: repository,
      syncStatusRepository: syncStatusRepository,
      connectivityHelper: connectivityHelper,
    );
  }

  static SyncService<Collaborator> createCollaboratorSyncService() {
    final repository =
        RepositoryFactory.createCollaboratorRepository()
            as CollaboratorRepository;
    final syncStatusRepository = SyncStatusRepository();
    final connectivityHelper = ConnectivityHelper();

    return CollaboratorSyncService(
      localRepository: repository,
      syncStatusRepository: syncStatusRepository,
      connectivityHelper: connectivityHelper,
    );
  }

  static SyncService<Payment> createPaymentSyncService() {
    final repository =
        RepositoryFactory.createPaymentRepository() as PaymentRepository;
    final syncStatusRepository = SyncStatusRepository();
    final connectivityHelper = ConnectivityHelper();

    return PaymentSyncService(
      localRepository: repository,
      syncStatusRepository: syncStatusRepository,
      connectivityHelper: connectivityHelper,
    );
  }

  static SyncService<User> createUserSyncService() {
    final repository =
        RepositoryFactory.createUserRepository() as UserRepository;
    final syncStatusRepository = SyncStatusRepository();
    final connectivityHelper = ConnectivityHelper();

    return UserSyncService(
      localRepository: repository,
      syncStatusRepository: syncStatusRepository,
      connectivityHelper: connectivityHelper,
    );
  }

  static SyncManager createSyncManager() {
    final connectivityHelper = ConnectivityHelper();
    final syncManager = SyncManager(connectivityHelper);

    // Registrar todos os serviços de sincronização
    syncManager.registerSyncService(createActivitySyncService());
    syncManager.registerSyncService(createCollaboratorSyncService());
    syncManager.registerSyncService(createPaymentSyncService());
    syncManager.registerSyncService(createUserSyncService());

    return syncManager;
  }
}
