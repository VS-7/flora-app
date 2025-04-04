import '../../domain/interfaces/repository.dart';
import '../../domain/models/activity_model.dart';
import '../../domain/models/collaborator_model.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/models/user_model.dart';
import '../repositories/activity_repository.dart';
import '../repositories/collaborator_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/user_repository.dart';

class RepositoryFactory {
  static Repository<User> createUserRepository() {
    return UserRepository();
  }

  static Repository<Activity> createActivityRepository() {
    return ActivityRepository();
  }

  static Repository<Collaborator> createCollaboratorRepository() {
    return CollaboratorRepository();
  }

  static Repository<Payment> createPaymentRepository() {
    return PaymentRepository();
  }
}
