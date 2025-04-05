import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/activity_model.dart';
import '../../providers/activity_provider.dart';
import '../../../utils/app_theme.dart';

class ActivityFormScreen extends StatefulWidget {
  final DateTime selectedDate;

  const ActivityFormScreen({Key? key, required this.selectedDate})
    : super(key: key);

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _areaController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  ActivityType _selectedType = ActivityType.other;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
    _areaController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Aplicar template com base no tipo de atividade selecionado
  void _applyTemplate(ActivityType type) {
    setState(() {
      _selectedType = type;

      // Limpar campos atuais
      _descriptionController.clear();

      // Preencher com template baseado no tipo
      switch (type) {
        case ActivityType.harvest:
          _descriptionController.text = 'Colheita de café';
          break;
        case ActivityType.pruning:
          _descriptionController.text = 'Poda de café';
          break;
        case ActivityType.fertilize:
          _descriptionController.text = 'Adubação';
          break;
        case ActivityType.spray:
          _descriptionController.text = 'Pulverização';
          break;
        case ActivityType.watering:
          _descriptionController.text = 'Irrigação';
          break;
        case ActivityType.weeding:
          _descriptionController.text = 'Capina';
          break;
        case ActivityType.planting:
          _descriptionController.text = 'Plantio';
          break;
        case ActivityType.other:
          _descriptionController.text = '';
          break;
      }
    });
  }

  // Salvar atividade
  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final activityProvider = Provider.of<ActivityProvider>(
        context,
        listen: false,
      );

      // Converter valores dos campos
      final double? cost =
          _costController.text.isNotEmpty
              ? double.tryParse(_costController.text.replaceAll(',', '.'))
              : null;

      final double? area =
          _areaController.text.isNotEmpty
              ? double.tryParse(_areaController.text.replaceAll(',', '.'))
              : null;

      final int? quantity =
          _quantityController.text.isNotEmpty
              ? int.tryParse(_quantityController.text)
              : null;

      await activityProvider.addActivity(
        date: widget.selectedDate,
        type: _selectedType,
        description: _descriptionController.text.trim(),
        cost: cost,
        areaInHectares: area,
        quantityInBags: quantity,
        notes:
            _notesController.text.isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atividade salva com sucesso!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Atividade'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Data selecionada
                Card(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppTheme.primaryDarkGreen,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Data: ${widget.selectedDate.day.toString().padLeft(2, '0')}/${widget.selectedDate.month.toString().padLeft(2, '0')}/${widget.selectedDate.year}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDarkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tipo de atividade
                Text(
                  'Tipo de Atividade',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: ActivityType.values.length,
                    itemBuilder: (context, index) {
                      final type = ActivityType.values[index];
                      final isSelected = type == _selectedType;

                      return InkWell(
                        onTap: () => _applyTemplate(type),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppTheme.primaryGreen
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getActivityIcon(type),
                                size: 20,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Descrição da atividade
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição da atividade',
                    hintText: 'Ex: Colheita de café no talhão 3',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe uma descrição para a atividade';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Custo
                TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+[,.]?\d{0,2}$'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Custo (R\$)',
                    hintText: 'Ex: 150,00',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Área
                TextFormField(
                  controller: _areaController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+[,.]?\d{0,2}$'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Área (hectares)',
                    hintText: 'Ex: 2,5',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Quantidade
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Quantidade (sacas)',
                    hintText: 'Ex: 30',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Observações
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    hintText: 'Informações adicionais',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Botão salvar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _saveActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isSubmitting
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'SALVAR ATIVIDADE',
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

  // Ícone correspondente ao tipo de atividade
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.harvest:
        return Icons.agriculture;
      case ActivityType.pruning:
        return Icons.content_cut;
      case ActivityType.fertilize:
        return Icons.spa;
      case ActivityType.spray:
        return Icons.flourescent;
      case ActivityType.watering:
        return Icons.water_drop;
      case ActivityType.weeding:
        return Icons.grass;
      case ActivityType.planting:
        return Icons.eco;
      case ActivityType.other:
        return Icons.more_horiz;
    }
  }
}
