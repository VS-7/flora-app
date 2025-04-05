import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../domain/factories/service_factory.dart';
import '../../domain/services/activity_service.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/collaborator_service.dart';
import '../../domain/services/payment_service.dart';
import '../../domain/services/user_service.dart';
import '../providers/activity_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class ProviderFactory {
  static UserProvider createUserProvider() {
    final userService = ServiceFactory.createUserService() as UserService;
    return UserProvider(userService: userService);
  }

  static ActivityProvider createActivityProvider() {
    final activityService =
        ServiceFactory.createActivityService() as ActivityService;
    final collaboratorService =
        ServiceFactory.createCollaboratorService() as CollaboratorService;
    final paymentService =
        ServiceFactory.createPaymentService() as PaymentService;

    return ActivityProvider(
      activityService: activityService,
      collaboratorService: collaboratorService,
      paymentService: paymentService,
    );
  }

  static AuthProvider createAuthProvider() {
    final authService = ServiceFactory.createAuthService() as AuthService;
    return AuthProvider(authService: authService);
  }

  static List<SingleChildWidget> createProviders() {
    return [
      ChangeNotifierProvider<UserProvider>(create: (_) => createUserProvider()),
      ChangeNotifierProvider<ActivityProvider>(
        create: (_) => createActivityProvider(),
      ),
      ChangeNotifierProvider<AuthProvider>(create: (_) => createAuthProvider()),
    ];
  }
}
