import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/product_model.dart';
import '../../../presentation/providers/product_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../utils/app_theme.dart';

class ProductBottomSheet extends StatefulWidget {
  final Product?
  product; // Pode ser null para criação, ou um produto para edição

  const ProductBottomSheet({Key? key, this.product}) : super(key: key);

  @override
  _ProductBottomSheetState createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _statusController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Preencher campos se for edição
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _typeController.text = widget.product!.type;
      _quantityController.text = widget.product!.quantity.toString();
      _statusController.text = widget.product!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _quantityController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Verificar se há uma fazenda selecionada
      if (farmProvider.currentFarm == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhuma fazenda selecionada')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final name = _nameController.text.trim();
      final type = _typeController.text.trim();
      final quantity = int.parse(_quantityController.text.trim());
      final status = _statusController.text.trim();

      try {
        if (widget.product == null) {
          // Criar novo produto
          await productProvider.createProduct(
            name: name,
            type: type,
            quantity: quantity,
            status: status,
            farmId: farmProvider.currentFarm!.id,
          );
        } else {
          // Atualizar produto existente
          await productProvider.updateProduct(
            id: widget.product!.id,
            name: name,
            type: type,
            quantity: quantity,
            status: status,
          );
        }

        if (mounted) {
          Navigator.pop(context, true); // Retornar sucesso
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
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
    final isEditing = widget.product != null;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 20;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1D1D1D) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título do BottomSheet
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Editar Produto' : 'Novo Produto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Nome do produto
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tipo
            TextFormField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Tipo é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Quantidade
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Quantidade é obrigatória';
                }
                try {
                  final quantity = int.parse(value);
                  if (quantity < 0) {
                    return 'Quantidade deve ser maior ou igual a zero';
                  }
                } catch (e) {
                  return 'Digite um valor válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Status
            TextFormField(
              controller: _statusController,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Status é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Botão de salvar
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        isEditing ? 'Atualizar' : 'Adicionar',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              // Botão de excluir
              OutlinedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          // Mostrar confirmação antes de excluir
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Confirmar exclusão'),
                                  content: const Text(
                                    'Tem certeza que deseja excluir este produto?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true && mounted) {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              final productProvider =
                                  Provider.of<ProductProvider>(
                                    context,
                                    listen: false,
                                  );
                              await productProvider.deleteProduct(
                                widget.product!.id,
                              );
                              if (mounted) {
                                Navigator.pop(context, true);
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro: ${e.toString()}'),
                                  ),
                                );
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }
                        },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Excluir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
