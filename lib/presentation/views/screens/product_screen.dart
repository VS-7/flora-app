import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/product_model.dart';
import '../../../presentation/providers/product_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../utils/app_theme.dart';
import '../components/product_bottom_sheet.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
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
    // Carregar produtos apenas na primeira vez
    if (!_isInit) {
      _loadProducts();
      _isInit = true;
    }
  }

  Future<void> _loadProducts() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    if (farmProvider.currentFarm != null) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      await productProvider.loadProductsByFarmId(farmProvider.currentFarm!.id);
    }
  }

  Future<void> _showAddEditProductBottomSheet(
    BuildContext context, [
    Product? product,
  ]) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SingleChildScrollView(
            child: ProductBottomSheet(product: product),
          ),
    );

    if (result == true) {
      // Recarregar lista se o produto foi adicionado/atualizado/excluído
      _loadProducts();
    }
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_searchQuery.isEmpty) {
      return products;
    }

    return products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.type.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final productProvider = Provider.of<ProductProvider>(context);
    final filteredProducts = _filterProducts(productProvider.products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        centerTitle: true,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditProductBottomSheet(context),
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
                hintText: 'Pesquisar produtos...',
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

          // Lista de produtos ou mensagem de lista vazia
          Expanded(
            child:
                productProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredProducts.isEmpty
                    ? _buildEmptyState(isDarkMode)
                    : _buildProductList(filteredProducts, isDarkMode),
          ),
        ],
      ),

      // Botão flutuante apenas se não houver produtos
      floatingActionButton:
          productProvider.products.isEmpty
              ? FloatingActionButton(
                onPressed: () => _showAddEditProductBottomSheet(context),
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
            Icons.inventory_2_outlined,
            size: 70,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto cadastrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro produto',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditProductBottomSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Produto'),
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

  Widget _buildProductList(List<Product> products, bool isDarkMode) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemCount: products.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
            indent: 80, // Indentação para alinhar com o avatar
          ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getProductTypeColor(product.type),
            child: Icon(
              _getProductTypeIcon(product.type),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.type,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              Text(
                'Quantidade: ${product.quantity}',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(product.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              product.status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () => _showAddEditProductBottomSheet(context, product),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
        );
      },
    );
  }

  Color _getProductTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fertilizante':
        return Colors.green[700]!;
      case 'herbicida':
        return Colors.red[700]!;
      case 'inseticida':
        return Colors.orange[700]!;
      case 'fungicida':
        return Colors.blue[700]!;
      case 'semente':
        return Colors.brown[700]!;
      default:
        return Colors.purple[700]!;
    }
  }

  IconData _getProductTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fertilizante':
        return Icons.grass;
      case 'herbicida':
        return Icons.local_florist;
      case 'inseticida':
        return Icons.bug_report;
      case 'fungicida':
        return Icons.coronavirus;
      case 'semente':
        return Icons.spa;
      default:
        return Icons.science;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disponível':
      case 'disponivel':
        return Colors.green[700]!;
      case 'em uso':
        return Colors.blue[700]!;
      case 'baixo estoque':
        return Colors.orange[700]!;
      case 'indisponível':
      case 'indisponivel':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}
