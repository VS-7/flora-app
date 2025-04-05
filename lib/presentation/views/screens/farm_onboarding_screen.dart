import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../presentation/providers/user_provider.dart';
import 'main_screen.dart';

class FarmOnboardingScreen extends StatefulWidget {
  const FarmOnboardingScreen({Key? key}) : super(key: key);

  @override
  _FarmOnboardingScreenState createState() => _FarmOnboardingScreenState();
}

class _FarmOnboardingScreenState extends State<FarmOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controladores para os campos de entrada
  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalAreaController = TextEditingController();
  final _mainCropController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _totalAreaController.dispose();
    _mainCropController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    if (authProvider.currentAuth == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não autenticado')));
      return;
    }

    double? totalArea;
    if (_totalAreaController.text.isNotEmpty) {
      totalArea = double.tryParse(_totalAreaController.text);
    }

    final farm = await farmProvider.createFarm(
      name: _farmNameController.text,
      userId: authProvider.currentAuth!.id,
      location:
          _locationController.text.isEmpty ? null : _locationController.text,
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      totalArea: totalArea,
      mainCrop:
          _mainCropController.text.isEmpty ? null : _mainCropController.text,
    );

    if (farm != null && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final farmProvider = Provider.of<FarmProvider>(context);

    // Se o usuário já tiver uma fazenda configurada, vá para a tela principal
    if (farmProvider.hasFarms) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração da Fazenda'),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: [
            // Página 1: Boas-vindas
            _buildWelcomePage(),

            // Página 2: Informações básicas
            _buildBasicInfoPage(),

            // Página 3: Detalhes adicionais
            _buildAdditionalDetailsPage(),

            // Página 4: Confirmação
            _buildConfirmationPage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                ElevatedButton(
                  onPressed: _previousPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Voltar'),
                )
              else
                const SizedBox.shrink(),

              if (_currentPage < 3)
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Próximo'),
                )
              else
                ElevatedButton(
                  onPressed: farmProvider.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      farmProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Concluir'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco, size: 100, color: Colors.green),
          const SizedBox(height: 32),
          Text(
            'Bem-vindo ao Flora App',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Vamos configurar sua fazenda para começar a usar o aplicativo.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Text(
            'Nas próximas telas, você fornecerá informações básicas sobre sua fazenda para personalizar sua experiência.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações Básicas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _farmNameController,
            decoration: const InputDecoration(
              labelText: 'Nome da Fazenda',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, informe o nome da fazenda';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Localização (opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'O nome da fazenda é usado para identificar sua propriedade no sistema e será mostrado em todos os relatórios e registros.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes Adicionais',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _totalAreaController,
            decoration: const InputDecoration(
              labelText: 'Área Total (hectares, opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.crop_square),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final number = double.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Por favor, informe um número válido';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mainCropController,
            decoration: const InputDecoration(
              labelText: 'Cultura Principal (opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.grass),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          const Text(
            'Estas informações são opcionais e ajudam a personalizar melhor sua experiência no aplicativo.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirme suas Informações',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          _buildInfoCard(
            'Nome da Fazenda',
            _farmNameController.text.isEmpty
                ? 'Não informado'
                : _farmNameController.text,
            Icons.business,
          ),
          _buildInfoCard(
            'Localização',
            _locationController.text.isEmpty
                ? 'Não informado'
                : _locationController.text,
            Icons.location_on,
          ),
          _buildInfoCard(
            'Área Total',
            _totalAreaController.text.isEmpty
                ? 'Não informado'
                : '${_totalAreaController.text} hectares',
            Icons.crop_square,
          ),
          _buildInfoCard(
            'Cultura Principal',
            _mainCropController.text.isEmpty
                ? 'Não informado'
                : _mainCropController.text,
            Icons.grass,
          ),
          const SizedBox(height: 32),
          const Text(
            'Verifique se todas as informações estão corretas antes de finalizar. Você poderá editar estes dados posteriormente nas configurações.',
            style: TextStyle(color: Colors.grey),
          ),

          // Exibir mensagem de erro, se houver
          Consumer<FarmProvider>(
            builder: (context, farmProvider, child) {
              if (farmProvider.error != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    farmProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
