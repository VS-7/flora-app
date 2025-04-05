import '../../domain/interfaces/repository.dart';
import '../../domain/models/activity_model.dart';
import '../../domain/models/collaborator_model.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/models/user_model.dart';
import '../repositories/activity_repository.dart';
import '../repositories/collaborator_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/sync_status_repository.dart';
import '../repositories/sync_aware_repository.dart';

class RepositoryFactory {
  static Repository<User> createUserRepository({bool syncAware = false}) {
    final baseRepo = UserRepository();
    if (!syncAware) return baseRepo;

    return SyncAwareRepository<User>(baseRepo, SyncStatusRepository(), 'user');
  }

  static Repository<Activity> createActivityRepository({
    bool syncAware = false,
  }) {
    final baseRepo = ActivityRepository();
    if (!syncAware) return baseRepo;

    return SyncAwareRepository<Activity>(
      baseRepo,
      SyncStatusRepository(),
      'activity',
    );
  }

  static Repository<Collaborator> createCollaboratorRepository({
    bool syncAware = false,
  }) {
    final baseRepo = CollaboratorRepository();
    if (!syncAware) return baseRepo;

    return SyncAwareRepository<Collaborator>(
      baseRepo,
      SyncStatusRepository(),
      'collaborator',
    );
  }

  static Repository<Payment> createPaymentRepository({bool syncAware = false}) {
    final baseRepo = PaymentRepository();
    if (!syncAware) return baseRepo;

    return SyncAwareRepository<Payment>(
      baseRepo,
      SyncStatusRepository(),
      'payment',
    );
  }
}
