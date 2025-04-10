import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/harvest_model.dart';
import '../../../domain/models/talhao_model.dart';
import '../../../domain/models/product_model.dart';
import '../../../presentation/providers/harvest_provider.dart';
import '../../../presentation/providers/talhao_provider.dart';
import '../../../presentation/providers/product_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../utils/app_theme.dart';
import '../components/harvest_bottom_sheet.dart';

class HarvestScreen extends StatefulWidget {
  const HarvestScreen({Key? key}) : super(key: key);

  @override
  _HarvestScreenState createState() => _HarvestScreenState();
}

class _HarvestScreenState extends State<HarvestScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isInit = false;
  Harvest? _selectedHarvest;
  bool _showingDetails = false;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterTalhaoId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carregar colheitas apenas na primeira vez
    if (!_isInit) {
      _loadData();
      _isInit = true;
    }
  }

  Future<void> _loadData() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    if (farmProvider.currentFarm != null) {
      // Carregar talhões se não estiverem carregados
      final talhaoProvider = Provider.of<TalhaoProvider>(
        context,
        listen: false,
      );
      if (!talhaoProvider.hasTalhoes) {
        await talhaoProvider.loadTalhoesByFarmId(farmProvider.currentFarm!.id);
      }

      // Carregar produtos se não estiverem carregados
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      if (!productProvider.hasProducts) {
        await productProvider.loadProductsByFarmId(
          farmProvider.currentFarm!.id,
        );
      }

      // Carregar colheitas
      final harvestProvider = Provider.of<HarvestProvider>(
        context,
        listen: false,
      );
      await harvestProvider.loadHarvestsByFarmId(farmProvider.currentFarm!.id);
    }
  }

  Future<void> _applyFilters() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final harvestProvider = Provider.of<HarvestProvider>(
      context,
      listen: false,
    );

    if (farmProvider.currentFarm == null) return;

    if (_filterTalhaoId != null && _filterTalhaoId!.isNotEmpty) {
      // Filtrar por talhão
      await harvestProvider.loadHarvestsByTalhaoId(_filterTalhaoId!);
    } else if (_filterStartDate != null && _filterEndDate != null) {
      // Filtrar por período
      await harvestProvider.loadHarvestsByDateRange(
        _filterStartDate!,
        _filterEndDate!,
        farmProvider.currentFarm!.id,
      );
    } else {
      // Carregar todas as colheitas
      await harvestProvider.loadHarvestsByFarmId(farmProvider.currentFarm!.id);
    }
  }

  void _resetFilters() {
    setState(() {
      _filterStartDate = null;
      _filterEndDate = null;
      _filterTalhaoId = null;
    });
    _loadData();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange:
          _filterStartDate != null && _filterEndDate != null
              ? DateTimeRange(start: _filterStartDate!, end: _filterEndDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filterStartDate = picked.start;
        _filterEndDate = picked.end;
      });
      _applyFilters();
    }
  }

  Future<void> _showAddEditHarvestBottomSheet(
    BuildContext context, [
    Harvest? harvest,
  ]) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SingleChildScrollView(
            child: HarvestBottomSheet(harvest: harvest),
          ),
    );

    if (result == true) {
      // Recarregar lista se a colheita foi adicionada/atualizada/excluída
      _loadData();
      setState(() {
        _showingDetails = false;
        _selectedHarvest = null;
      });
    }
  }

  List<Harvest> _filterHarvests(List<Harvest> harvests) {
    if (_searchQuery.isEmpty) {
      return harvests;
    }

    return harvests.where((harvest) {
      return harvest.coffeeType.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();
  }

  void _viewHarvestDetails(Harvest harvest) {
    setState(() {
      _selectedHarvest = harvest;
      _showingDetails = true;
    });
  }

  void _closeDetails() {
    setState(() {
      _showingDetails = false;
      _selectedHarvest = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final harvestProvider = Provider.of<HarvestProvider>(context);
    final talhaoProvider = Provider.of<TalhaoProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final filteredHarvests = _filterHarvests(harvestProvider.harvests);
    final talhoes = talhaoProvider.talhoes;

    if (_showingDetails && _selectedHarvest != null) {
      return _buildHarvestDetailsScreen(
        _selectedHarvest!,
        isDarkMode,
        talhaoProvider,
        productProvider,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Colheita'),
        centerTitle: true,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Filtrar por data',
            onPressed: () => _selectDateRange(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Mais filtros',
            onPressed: () => _showFilterDialog(context, talhoes),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditHarvestBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de filtros ativos
          if (_filterStartDate != null ||
              _filterEndDate != null ||
              _filterTalhaoId != null)
            _buildActiveFiltersBar(talhoes),

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
                hintText: 'Pesquisar colheitas...',
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

          // Lista de colheitas ou mensagem de lista vazia
          Expanded(
            child:
                harvestProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredHarvests.isEmpty
                    ? _buildEmptyState(isDarkMode)
                    : _buildHarvestList(
                      filteredHarvests,
                      isDarkMode,
                      talhaoProvider,
                    ),
          ),
        ],
      ),

      // Botão flutuante apenas se não houver colheitas
      floatingActionButton:
          harvestProvider.harvests.isEmpty
              ? FloatingActionButton(
                onPressed: () => _showAddEditHarvestBottomSheet(context),
                backgroundColor: AppTheme.primaryGreen,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildActiveFiltersBar(List<Talhao> talhoes) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    String filterText = '';
    if (_filterStartDate != null && _filterEndDate != null) {
      final dateFormat = DateFormat('dd/MM/yyyy');
      filterText +=
          '${dateFormat.format(_filterStartDate!)} - ${dateFormat.format(_filterEndDate!)}';
    }

    if (_filterTalhaoId != null) {
      final talhao = talhoes.firstWhere(
        (t) => t.id == _filterTalhaoId,
        orElse:
            () => Talhao(
              id: '',
              name: 'Desconhecido',
              area: 0,
              currentHarvest: '',
              farmId: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      );
      if (filterText.isNotEmpty) filterText += ' | ';
      filterText += 'Talhão: ${talhao.name}';
    }

    return Container(
      color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filtros: $filterText',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              size: 18,
            ),
            onPressed: _resetFilters,
            tooltip: 'Limpar filtros',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(
    BuildContext context,
    List<Talhao> talhoes,
  ) async {
    String? selectedTalhaoId = _filterTalhaoId;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filtrar Colheitas'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filtrar por Talhão:'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedTalhaoId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: const Text('Selecione um talhão'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Todos os talhões'),
                        ),
                        ...talhoes.map((talhao) {
                          return DropdownMenuItem<String>(
                            value: talhao.id,
                            child: Text(talhao.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedTalhaoId = value == '' ? null : value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      _filterTalhaoId = selectedTalhaoId;
                      if (selectedTalhaoId != null) {
                        // Se um talhão é selecionado, limpar filtros de data
                        _filterStartDate = null;
                        _filterEndDate = null;
                      }
                    });
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_florist_outlined,
            size: 70,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma colheita registrada',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registre sua primeira colheita',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditHarvestBottomSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Colheita'),
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

  Widget _buildHarvestList(
    List<Harvest> harvests,
    bool isDarkMode,
    TalhaoProvider talhaoProvider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: harvests.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            indent: 80, // Indentação para alinhar com o avatar
          ),
      itemBuilder: (context, index) {
        final harvest = harvests[index];

        // Encontrar o talhão correspondente
        final talhao = talhaoProvider.talhoes.firstWhere(
          (t) => t.id == harvest.talhaoId,
          orElse:
              () => Talhao(
                id: '',
                name: 'Desconhecido',
                area: 0,
                currentHarvest: '',
                farmId: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        );

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
            child: Icon(
              Icons.local_florist,
              color: AppTheme.primaryGreen,
              size: 20,
            ),
          ),
          title: Text(
            '${harvest.coffeeType} - ${dateFormat.format(harvest.startDate)}',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Talhão: ${talhao.name}',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              Text(
                'Quantidade: ${harvest.totalQuantity} sacas',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed:
                    () => _showAddEditHarvestBottomSheet(context, harvest),
                color: isDarkMode ? Colors.blue[300] : Colors.blue,
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: () => _viewHarvestDetails(harvest),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        );
      },
    );
  }

  Widget _buildHarvestDetailsScreen(
    Harvest harvest,
    bool isDarkMode,
    TalhaoProvider talhaoProvider,
    ProductProvider productProvider,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Encontrar o talhão correspondente
    final talhao = talhaoProvider.talhoes.firstWhere(
      (t) => t.id == harvest.talhaoId,
      orElse:
          () => Talhao(
            id: '',
            name: 'Desconhecido',
            area: 0,
            currentHarvest: '',
            farmId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );

    // Buscar produtos utilizados
    List<Product> usedProductsList = [];
    if (harvest.usedProducts != null && harvest.usedProducts!.isNotEmpty) {
      usedProductsList =
          productProvider.products
              .where((p) => harvest.usedProducts!.contains(p.id))
              .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Colheita'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _closeDetails,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showAddEditHarvestBottomSheet(context, harvest),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal com informações da colheita
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_florist,
                          color: AppTheme.primaryGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            harvest.coffeeType,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Data de Início:',
                      dateFormat.format(harvest.startDate),
                      Icons.calendar_today,
                    ),
                    _buildDetailRow('Talhão:', talhao.name, Icons.crop_square),
                    _buildDetailRow(
                      'Área do Talhão:',
                      '${talhao.area.toStringAsFixed(2)} ha',
                      Icons.straighten,
                    ),
                    _buildDetailRow(
                      'Quantidade Total:',
                      '${harvest.totalQuantity} sacas',
                      Icons.inventory,
                    ),
                    _buildDetailRow(
                      'Qualidade:',
                      '${harvest.quality}/100',
                      Icons.star,
                    ),
                    if (harvest.weather != null && harvest.weather!.isNotEmpty)
                      _buildDetailRow(
                        'Condições Climáticas:',
                        harvest.weather!,
                        Icons.wb_sunny,
                      ),
                  ],
                ),
              ),
            ),

            // Lista de produtos utilizados
            if (usedProductsList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'Produtos Utilizados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: usedProductsList.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = usedProductsList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                        child: Icon(
                          Icons.science,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        '${product.type}',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Text(
                  'Nenhum produto utilizado',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
