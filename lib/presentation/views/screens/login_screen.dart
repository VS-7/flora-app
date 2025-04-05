import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/user_provider.dart';
import 'main_screen.dart';
import 'user_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Se o usuário já estiver autenticado, direcionar para a tela principal
    if (authProvider.isAuthenticated && userProvider.isUserRegistered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.green),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo ou imagem do app
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Icon(Icons.eco, size: 80, color: Colors.green),
              ),

              // Título
              Text(
                'Flora App',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Campo de email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite seu email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Por favor, digite um email válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo de senha
              TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite sua senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),

              // Mensagem de erro
              if (authProvider.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    authProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 24),

              // Botão de login
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    authProvider.isLoading
                        ? null
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await authProvider.login(
                              _emailController.text,
                              _passwordController.text,
                            );

                            if (success) {
                              // Verificar se o usuário já está registrado no app
                              await userProvider.initialize();

                              if (userProvider.isUserRegistered) {
                                if (mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const MainScreen(),
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const UserRegistrationScreen(),
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                child:
                    authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ENTRAR'),
              ),

              const SizedBox(height: 16),

              // Opção para registrar
              TextButton(
                onPressed: () {
                  // Aqui você poderia adicionar uma navegação para a tela de registro
                  // caso queira implementar essa funcionalidade no futuro
                },
                child: const Text(
                  'Não tem uma conta? Entre em contato para criar',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
