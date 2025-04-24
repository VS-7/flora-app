import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/harvest_model.dart';
import '../../../presentation/providers/harvest_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../utils/app_theme.dart';

class YearlyHarvestFormScreen extends StatefulWidget {
  final Harvest? harvest; // Null para criação, não-null para edição

  const YearlyHarvestFormScreen({Key? key, this.harvest}) : super(key: key);

  @override
  State<YearlyHarvestFormScreen> createState() =>
      _YearlyHarvestFormScreenState();
}

class _YearlyHarvestFormScreenState extends State<YearlyHarvestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late int _selectedYear;
  late DateTime _startDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores
    _nameController = TextEditingController(text: widget.harvest?.name ?? '');

    // Inicializar ano e data de início
    if (widget.harvest != null) {
      _selectedYear = widget.harvest!.year;
      _startDate = widget.harvest!.startDate;
    } else {
      final now = DateTime.now();
      _selectedYear = now.year;
      _startDate = DateTime(now.year, now.month, now.day);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(_selectedYear, 1, 1),
      lastDate: DateTime(_selectedYear, 12, 31),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _saveHarvest() async {
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
      final harvestProvider = Provider.of<HarvestProvider>(
        context,
        listen: false,
      );

      if (widget.harvest == null) {
        // Criação
        await harvestProvider.createYearlyHarvest(
          name: _nameController.text,
          year: _selectedYear,
          startDate: _startDate,
          farmId: farmProvider.currentFarm!.id,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Colheita anual criada com sucesso')),
        );
      } else {
        // Edição
        final success = await harvestProvider.updateHarvest(
          id: widget.harvest!.id,
          name: _nameController.text,
          year: _selectedYear,
          startDate: _startDate,
        );
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Colheita anual atualizada com sucesso'),
            ),
          );
        }
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar colheita: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.harvest == null
              ? 'Nova Colheita Anual'
              : 'Editar Colheita Anual',
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
                      // Nome da Colheita
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Colheita',
                          border: OutlineInputBorder(),
                          hintText: 'Ex: Colheita 2025',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira um nome para a colheita';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Ano da Colheita
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Ano da Colheita',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedYear,
                        items: List.generate(10, (index) {
                          final year =
                              DateTime.now().year +
                              index -
                              3; // 3 anos atrás até 6 anos à frente
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedYear = value;
                              // Ajustar a data de início para o novo ano
                              _startDate = DateTime(
                                value,
                                _startDate.month,
                                _startDate.day,
                              );
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecione um ano para a colheita';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Data de Início
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data de Início',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
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
                          onPressed: _saveHarvest,
                          child: Text(
                            widget.harvest == null
                                ? 'Criar Colheita Anual'
                                : 'Atualizar Colheita Anual',
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
