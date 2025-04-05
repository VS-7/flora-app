import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/user_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'user_registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Aguarde um pouco para mostrar a splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Inicialize os providers
    await authProvider.initialize();
    await userProvider.initialize();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      if (userProvider.isUserRegistered) {
        // Se estiver autenticado e registrado, vá para a tela principal
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        // Se estiver autenticado mas não registrado, vá para registro
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UserRegistrationScreen()),
        );
      }
    } else {
      // Se não estiver autenticado, vá para login
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou ícone
            Icon(Icons.eco, size: 100, color: Colors.green),

            const SizedBox(height: 24),

            // Nome do app
            Text(
              'Flora App',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 48),

            // Indicador de carregamento
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
