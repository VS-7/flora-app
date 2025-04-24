import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/farm_activity_model.dart';
import '../../../presentation/providers/farm_activity_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../presentation/providers/harvest_provider.dart';
import '../../../presentation/providers/talhao_provider.dart';
import '../../../presentation/providers/employee_provider.dart';
import '../../../presentation/providers/product_provider.dart';
import '../../../utils/app_theme.dart';

class FarmActivityFormScreen extends StatefulWidget {
  final FarmActivity? activity; // Null para criação, não-null para edição
  final DateTime? preselectedDate; // Para pré-selecionar a data ao criar

  const FarmActivityFormScreen({Key? key, this.activity, this.preselectedDate})
    : super(key: key);

  @override
  State<FarmActivityFormScreen> createState() => _FarmActivityFormScreenState();
}

class _FarmActivityFormScreenState extends State<FarmActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  ActivityType _selectedType = ActivityType.other;
  String? _selectedTalhaoId;
  String? _selectedHarvestId;
  String? _selectedEmployeeId;
  List<String> _selectedProductIds = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores
    _titleController = TextEditingController(
      text: widget.activity?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.activity?.description ?? '',
    );

    // Inicializar data
    _selectedDate =
        widget.activity?.date ?? widget.preselectedDate ?? DateTime.now();

    // Se estivermos editando, carregue os outros campos
    if (widget.activity != null) {
      _selectedType = widget.activity!.type;
      _selectedTalhaoId = widget.activity!.talhaoId;
      _selectedHarvestId = widget.activity!.harvestId;
      _selectedEmployeeId = widget.activity!.employeeId;
      _selectedProductIds = widget.activity!.productIds?.toList() ?? [];
    }

    // Carregar dados necessários
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    if (farmProvider.currentFarm == null) return;

    final talhaoProvider = Provider.of<TalhaoProvider>(context, listen: false);
    final harvestProvider = Provider.of<HarvestProvider>(
      context,
      listen: false,
    );
    final employeeProvider = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    );
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    setState(() => _isLoading = true);

    try {
      await talhaoProvider.loadTalhoesByFarmId(farmProvider.currentFarm!.id);
      await harvestProvider.initialize(farmProvider.currentFarm!.id);
      await employeeProvider.loadEmployeesByFarmId(
        farmProvider.currentFarm!.id,
      );
      await productProvider.loadProductsByFarmId(farmProvider.currentFarm!.id);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    if (farmProvider.currentFarm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma fazenda selecionada')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final activityProvider = Provider.of<FarmActivityProvider>(
        context,
        listen: false,
      );

      final activity = FarmActivity(
        id: widget.activity?.id ?? '', // Vazio para criação
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        type: _selectedType,
        farmId: farmProvider.currentFarm!.id,
        talhaoId: _selectedTalhaoId,
        harvestId: _selectedHarvestId,
        employeeId: _selectedEmployeeId,
        productIds: _selectedProductIds.isEmpty ? null : _selectedProductIds,
        createdAt: widget.activity?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.activity == null) {
        // Criação
        await activityProvider.addActivity(activity);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atividade criada com sucesso')),
        );
      } else {
        // Edição
        final success = await activityProvider.updateActivity(activity);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Atividade atualizada com sucesso')),
          );
        }
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar atividade: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final talhaoProvider = Provider.of<TalhaoProvider>(context);
    final harvestProvider = Provider.of<HarvestProvider>(context);
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.activity == null ? 'Nova Atividade' : 'Editar Atividade',
        ),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira um título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descrição
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira uma descrição';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Data
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tipo de Atividade
                      DropdownButtonFormField<ActivityType>(
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Atividade',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedType,
                        items:
                            ActivityType.values.map((type) {
                              String label;
                              switch (type) {
                                case ActivityType.planting:
                                  label = 'Plantio';
                                  break;
                                case ActivityType.irrigation:
                                  label = 'Irrigação';
                                  break;
                                case ActivityType.fertilization:
                                  label = 'Adubação';
                                  break;
                                case ActivityType.pestControl:
                                  label = 'Controle de Pragas';
                                  break;
                                case ActivityType.pruning:
                                  label = 'Poda';
                                  break;
                                case ActivityType.harvesting:
                                  label = 'Colheita';
                                  break;
                                case ActivityType.maintenance:
                                  label = 'Manutenção';
                                  break;
                                case ActivityType.other:
                                default:
                                  label = 'Outro';
                                  break;
                              }

                              return DropdownMenuItem<ActivityType>(
                                value: type,
                                child: Text(label),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Talhão (Opcional)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Talhão (Opcional)',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedTalhaoId,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Nenhum'),
                          ),
                          ...talhaoProvider.talhoes.map((talhao) {
                            return DropdownMenuItem<String>(
                              value: talhao.id,
                              child: Text(talhao.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTalhaoId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Colheita (Opcional)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Colheita (Opcional)',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedHarvestId,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Nenhuma'),
                          ),
                          ...harvestProvider.harvests.map((harvest) {
                            return DropdownMenuItem<String>(
                              value: harvest.id,
                              child: Text(harvest.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedHarvestId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Funcionário Responsável (Opcional)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Funcionário Responsável (Opcional)',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedEmployeeId,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Nenhum'),
                          ),
                          ...employeeProvider.employees.map((employee) {
                            return DropdownMenuItem<String>(
                              value: employee.id,
                              child: Text(employee.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedEmployeeId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Botão de Salvar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          onPressed: _saveActivity,
                          child: Text(
                            widget.activity == null
                                ? 'Criar Atividade'
                                : 'Atualizar Atividade',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
