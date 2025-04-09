import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../utils/app_theme.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import 'main_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Verificar autenticação e navegar para a tela apropriada após delay
    Timer(const Duration(milliseconds: 2500), () {
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
    final isLoggedIn = await authProvider.checkAuthStatus();

    if (isLoggedIn && mounted) {
      // Se o usuário estiver logado, verificar se ele possui fazendas
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final hasFarms = await farmProvider.userHasFarms(
        authProvider.currentAuth!.id,
      );

      if (mounted) {
        if (hasFarms) {
          // Se o usuário tem fazendas, ir para a tela principal
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // Se o usuário não tem fazendas, ir para o onboarding
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    } else if (mounted) {
      // Se não estiver logado, ir para o login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.eco_outlined,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Flora App',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode
                                ? Colors.white
                                : AppTheme.primaryDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestão Rural Inteligente',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode
                              ? AppTheme.accentGreen
                              : AppTheme.primaryDarkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
