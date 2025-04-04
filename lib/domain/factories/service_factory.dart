import '../../data/factories/repository_factory.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/collaborator_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/interfaces/service.dart';
import '../../domain/models/activity_model.dart';
import '../../domain/models/collaborator_model.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/services/activity_service.dart';
import '../../domain/services/collaborator_service.dart';
import '../../domain/services/payment_service.dart';
import '../../domain/services/user_service.dart';

class ServiceFactory {
  static Service<User> createUserService() {
    final repository =
        RepositoryFactory.createUserRepository() as UserRepository;
    return UserService(repository);
  }

  static Service<Activity> createActivityService() {
    final repository =
        RepositoryFactory.createActivityRepository() as ActivityRepository;
    return ActivityService(repository);
  }

  static Service<Collaborator> createCollaboratorService() {
    final repository =
        RepositoryFactory.createCollaboratorRepository()
            as CollaboratorRepository;
    return CollaboratorService(repository);
  }

  static Service<Payment> createPaymentService() {
    final repository =
        RepositoryFactory.createPaymentRepository() as PaymentRepository;
    return PaymentService(repository);
  }
}
