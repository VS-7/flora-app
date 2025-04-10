import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/talhao_model.dart';
import '../../../presentation/providers/talhao_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../utils/app_theme.dart';
import '../components/talhao_bottom_sheet.dart';

class TalhaoScreen extends StatefulWidget {
  const TalhaoScreen({Key? key}) : super(key: key);

  @override
  _TalhaoScreenState createState() => _TalhaoScreenState();
}

class _TalhaoScreenState extends State<TalhaoScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isInit = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carregar talhões apenas na primeira vez
    if (!_isInit) {
      _loadTalhoes();
      _isInit = true;
    }
  }

  Future<void> _loadTalhoes() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    if (farmProvider.currentFarm != null) {
      final talhaoProvider = Provider.of<TalhaoProvider>(
        context,
        listen: false,
      );
      await talhaoProvider.loadTalhoesByFarmId(farmProvider.currentFarm!.id);
    }
  }

  Future<void> _showAddEditTalhaoBottomSheet(
    BuildContext context, [
    Talhao? talhao,
  ]) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              SingleChildScrollView(child: TalhaoBottomSheet(talhao: talhao)),
    );

    if (result == true) {
      // Recarregar lista se o talhão foi adicionado/atualizado/excluído
      _loadTalhoes();
    }
  }

  List<Talhao> _filterTalhoes(List<Talhao> talhoes) {
    if (_searchQuery.isEmpty) {
      return talhoes;
    }

    return talhoes.where((talhao) {
      return talhao.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          talhao.currentHarvest.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final talhaoProvider = Provider.of<TalhaoProvider>(context);
    final filteredTalhoes = _filterTalhoes(talhaoProvider.talhoes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Talhões'),
        centerTitle: true,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditTalhaoBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa estilo WhatsApp iOS
          Container(
            color:
                isDarkMode ? const Color(0xFF121212) : const Color(0xFFF6F6F6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar talhões...',
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode ? Colors.grey : Colors.grey[600],
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDarkMode ? Colors.grey : Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Lista de talhões ou mensagem de lista vazia
          Expanded(
            child:
                talhaoProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredTalhoes.isEmpty
                    ? _buildEmptyState(isDarkMode)
                    : _buildTalhaoList(filteredTalhoes, isDarkMode),
          ),
        ],
      ),

      // Botão flutuante apenas se não houver talhões
      floatingActionButton:
          talhaoProvider.talhoes.isEmpty
              ? FloatingActionButton(
                onPressed: () => _showAddEditTalhaoBottomSheet(context),
                backgroundColor: AppTheme.primaryGreen,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.crop_square_outlined,
            size: 70,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum talhão cadastrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro talhão',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditTalhaoBottomSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Talhão'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTalhaoList(List<Talhao> talhoes, bool isDarkMode) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: talhoes.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            indent: 80, // Indentação para alinhar com o avatar
          ),
      itemBuilder: (context, index) {
        final talhao = talhoes[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
            child: Icon(
              Icons.crop_square,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
          ),
          title: Text(
            talhao.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Colheita: ${talhao.currentHarvest}',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              Text(
                'Área: ${talhao.area.toStringAsFixed(2)} ha',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          onTap: () => _showAddEditTalhaoBottomSheet(context, talhao),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        );
      },
    );
  }
}
