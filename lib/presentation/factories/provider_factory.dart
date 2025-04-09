import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../domain/factories/service_factory.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/farm_service.dart';
import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';

class ProviderFactory {
  static AuthProvider createAuthProvider() {
    final authService = ServiceFactory.createAuthService() as AuthService;
    return AuthProvider(authService: authService);
  }

  static FarmProvider createFarmProvider() {
    final farmService = ServiceFactory.createFarmService() as FarmService;
    return FarmProvider(farmService: farmService);
  }

  static List<SingleChildWidget> createProviders() {
    return [
      ChangeNotifierProvider<AuthProvider>(create: (_) => createAuthProvider()),
      ChangeNotifierProvider<FarmProvider>(create: (_) => createFarmProvider()),
    ];
  }
}
