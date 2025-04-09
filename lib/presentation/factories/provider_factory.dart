import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import '../../domain/factories/service_factory.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/farm_service.dart';
import '../../domain/services/employee_service.dart';
import '../../domain/services/product_service.dart';
import '../../domain/services/talhao_service.dart';
import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';
import '../providers/employee_provider.dart';
import '../providers/product_provider.dart';
import '../providers/talhao_provider.dart';

class ProviderFactory {
  static AuthProvider createAuthProvider() {
    final authService = ServiceFactory.createAuthService() as AuthService;
    return AuthProvider(authService: authService);
  }

  static FarmProvider createFarmProvider() {
    final farmService = ServiceFactory.createFarmService() as FarmService;
    return FarmProvider(farmService: farmService);
  }

  static EmployeeProvider createEmployeeProvider() {
    final employeeService =
        ServiceFactory.createEmployeeService() as EmployeeService;
    return EmployeeProvider(employeeService: employeeService);
  }

  static ProductProvider createProductProvider() {
    final productService =
        ServiceFactory.createProductService() as ProductService;
    return ProductProvider(productService: productService);
  }

  static TalhaoProvider createTalhaoProvider() {
    final talhaoService = ServiceFactory.createTalhaoService() as TalhaoService;
    return TalhaoProvider(talhaoService: talhaoService);
  }

  static List<SingleChildWidget> createProviders() {
    return [
      ChangeNotifierProvider<AuthProvider>(create: (_) => createAuthProvider()),
      ChangeNotifierProvider<FarmProvider>(create: (_) => createFarmProvider()),
      ChangeNotifierProvider<EmployeeProvider>(
        create: (_) => createEmployeeProvider(),
      ),
      ChangeNotifierProvider<ProductProvider>(
        create: (_) => createProductProvider(),
      ),
      ChangeNotifierProvider<TalhaoProvider>(
        create: (_) => createTalhaoProvider(),
      ),
    ];
  }
}
