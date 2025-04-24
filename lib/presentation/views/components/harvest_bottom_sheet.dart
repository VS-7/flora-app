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

class HarvestBottomSheet extends StatefulWidget {
  final Harvest?
  harvest; // Pode ser null para criação, ou uma colheita para edição

  const HarvestBottomSheet({Key? key, this.harvest}) : super(key: key);

  @override
  _HarvestBottomSheetState createState() => _HarvestBottomSheetState();
}

class _HarvestBottomSheetState extends State<HarvestBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();

  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Preencher campos se for edição
    if (widget.harvest != null) {
      _selectedDate = widget.harvest!.startDate;
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      _nameController.text = widget.harvest!.name;
      _yearController.text = widget.harvest!.year.toString();
    } else {
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      _yearController.text = DateTime.now().year.toString();
    }

    // Carregar talhões se necessário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  Future<void> _saveHarvest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final harvestProvider = Provider.of<HarvestProvider>(
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
      final year = int.parse(_yearController.text.trim());

      try {
        if (widget.harvest == null) {
          // Criar nova colheita anual
          await harvestProvider.createYearlyHarvest(
            name: name,
            year: year,
            startDate: _selectedDate,
            farmId: farmProvider.currentFarm!.id,
          );
        } else {
          // Atualizar colheita existente
          await harvestProvider.updateHarvest(
            id: widget.harvest!.id,
            name: name,
            year: year,
            startDate: _selectedDate,
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
    final isEditing = widget.harvest != null;
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título do BottomSheet
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Editar Colheita' : 'Nova Colheita',
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

              // Nome da colheita
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome da Colheita',
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

              // Data da colheita
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Data de Início',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor:
                      isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Data é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ano
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Ano',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor:
                      isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ano é obrigatório';
                  }
                  try {
                    final year = int.parse(value);
                    if (year < 2000 || year > 2100) {
                      return 'Ano deve estar entre 2000 e 2100';
                    }
                  } catch (e) {
                    return 'Digite um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Botão de salvar
              ElevatedButton(
                onPressed: _isLoading ? null : _saveHarvest,
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
                                      'Tem certeza que deseja excluir esta colheita?',
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
                                final harvestProvider =
                                    Provider.of<HarvestProvider>(
                                      context,
                                      listen: false,
                                    );
                                await harvestProvider.deleteHarvest(
                                  widget.harvest!.id,
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
      ),
    );
  }
}
