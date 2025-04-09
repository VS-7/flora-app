import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/employee_model.dart';
import '../../../presentation/providers/employee_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../utils/app_theme.dart';

class EmployeeBottomSheet extends StatefulWidget {
  final Employee?
  employee; // Pode ser null para criação, ou um funcionário para edição

  const EmployeeBottomSheet({Key? key, this.employee}) : super(key: key);

  @override
  _EmployeeBottomSheetState createState() => _EmployeeBottomSheetState();
}

class _EmployeeBottomSheetState extends State<EmployeeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _costController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Preencher campos se for edição
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _roleController.text = widget.employee!.role;
      _costController.text = widget.employee!.cost.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(
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
      final role = _roleController.text.trim();
      final cost = double.parse(_costController.text.trim());

      try {
        if (widget.employee == null) {
          // Criar novo funcionário
          await employeeProvider.createEmployee(
            name: name,
            role: role,
            cost: cost,
            farmId: farmProvider.currentFarm!.id,
          );
        } else {
          // Atualizar funcionário existente
          await employeeProvider.updateEmployee(
            id: widget.employee!.id,
            name: name,
            role: role,
            cost: cost,
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
    final isEditing = widget.employee != null;
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
                  isEditing ? 'Editar Funcionário' : 'Novo Funcionário',
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

            // Nome do funcionário
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

            // Função/cargo
            TextFormField(
              controller: _roleController,
              decoration: InputDecoration(
                labelText: 'Função/Cargo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Função é obrigatória';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Custo (diária)
            TextFormField(
              controller: _costController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Valor da Diária (R\$)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor:
                    isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Valor da diária é obrigatório';
                }
                try {
                  final cost = double.parse(value);
                  if (cost <= 0) {
                    return 'O valor deve ser maior que zero';
                  }
                } catch (e) {
                  return 'Digite um valor válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Botão de salvar
            ElevatedButton(
              onPressed: _isLoading ? null : _saveEmployee,
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
                                    'Tem certeza que deseja excluir este funcionário?',
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
                              final employeeProvider =
                                  Provider.of<EmployeeProvider>(
                                    context,
                                    listen: false,
                                  );
                              await employeeProvider.deleteEmployee(
                                widget.employee!.id,
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
