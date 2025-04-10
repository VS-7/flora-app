import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/talhao_model.dart';
import '../../../presentation/providers/talhao_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../utils/app_theme.dart';

class TalhaoBottomSheet extends StatefulWidget {
  final Talhao? talhao; // Pode ser null para criação, ou um talhão para edição

  const TalhaoBottomSheet({Key? key, this.talhao}) : super(key: key);

  @override
  _TalhaoBottomSheetState createState() => _TalhaoBottomSheetState();
}

class _TalhaoBottomSheetState extends State<TalhaoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _currentHarvestController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Preencher campos se for edição
    if (widget.talhao != null) {
      _nameController.text = widget.talhao!.name;
      _areaController.text = widget.talhao!.area.toString();
      _currentHarvestController.text = widget.talhao!.currentHarvest;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _currentHarvestController.dispose();
    super.dispose();
  }

  Future<void> _saveTalhao() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final talhaoProvider = Provider.of<TalhaoProvider>(
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
      final area = double.parse(_areaController.text.trim());
      final currentHarvest = _currentHarvestController.text.trim();

      try {
        if (widget.talhao == null) {
          // Criar novo talhão
          await talhaoProvider.createTalhao(
            name: name,
            area: area,
            currentHarvest: currentHarvest,
            farmId: farmProvider.currentFarm!.id,
          );
        } else {
          // Atualizar talhão existente
          await talhaoProvider.updateTalhao(
            id: widget.talhao!.id,
            name: name,
            area: area,
            currentHarvest: currentHarvest,
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
    final isEditing = widget.talhao != null;
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
                  isEditing ? 'Editar Talhão' : 'Novo Talhão',
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

            // Nome do talhão
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Talhão',
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

            // Área em hectares
            TextFormField(
              controller: _areaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Área (hectares)',
                suffixText: 'ha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Área é obrigatória';
                }
                try {
                  final area = double.parse(value);
                  if (area <= 0) {
                    return 'A área deve ser maior que zero';
                  }
                } catch (e) {
                  return 'Digite um valor válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Colheita atual
            TextFormField(
              controller: _currentHarvestController,
              decoration: InputDecoration(
                labelText: 'Colheita Atual',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Colheita atual é obrigatória';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Botão de salvar
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTalhao,
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
                                    'Tem certeza que deseja excluir este talhão?',
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
                              final talhaoProvider =
                                  Provider.of<TalhaoProvider>(
                                    context,
                                    listen: false,
                                  );
                              await talhaoProvider.deleteTalhao(
                                widget.talhao!.id,
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
