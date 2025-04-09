import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/farm_model.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../utils/app_theme.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalAreaController = TextEditingController();
  final _mainCropController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _totalAreaController.dispose();
    _mainCropController.dispose();
    super.dispose();
  }

  Future<void> _saveFarm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);

      // Verificar se o usuário está logado
      if (!authProvider.isAuthenticated || authProvider.currentAuth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Extrair os valores dos campos
      final name = _nameController.text.trim();
      final location = _locationController.text.trim();
      final description = _descriptionController.text.trim();
      final totalArea =
          _totalAreaController.text.isNotEmpty
              ? double.tryParse(_totalAreaController.text)
              : null;
      final mainCrop = _mainCropController.text.trim();

      try {
        // Criar a fazenda
        final farm = await farmProvider.createFarm(
          name: name,
          userId: authProvider.currentAuth!.id,
          location: location.isNotEmpty ? location : null,
          description: description.isNotEmpty ? description : null,
          totalArea: totalArea,
          mainCrop: mainCrop.isNotEmpty ? mainCrop : null,
        );

        if (farm != null && mounted) {
          // Navegar para a tela principal
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(farmProvider.error ?? 'Falha ao salvar a fazenda'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.eco_outlined,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Bem-vindo ao Flora App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? Colors.white : AppTheme.primaryDarkGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Vamos configurar sua primeira fazenda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Campo de nome da fazenda
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome da Fazenda *',
                    prefixIcon: const Icon(Icons.home_work_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome da fazenda é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Campo de localização
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Localização',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Campo de área total
                TextFormField(
                  controller: _totalAreaController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Área Total (hectares)',
                    prefixIcon: const Icon(Icons.area_chart_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final doubleValue = double.tryParse(value);
                      if (doubleValue == null || doubleValue <= 0) {
                        return 'Informe um valor válido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Campo de cultura principal
                TextFormField(
                  controller: _mainCropController,
                  decoration: InputDecoration(
                    labelText: 'Cultura Principal',
                    prefixIcon: const Icon(Icons.grass_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Campo de descrição
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Botão de salvar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveFarm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            )
                            : const Text(
                              'CONTINUAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
