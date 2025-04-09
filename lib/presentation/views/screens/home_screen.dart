import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../utils/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-vindo(a)!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppTheme.primaryDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                authProvider.currentAuth?.email ?? 'Usuário',
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 100,
                        color:
                            isDarkMode
                                ? AppTheme.primaryGreen.withOpacity(0.7)
                                : AppTheme.primaryGreen,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Seu sistema de gestão rural',
                        style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Selecione as opções através do menu',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white60 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
