import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/activity_provider.dart';
import '../../../utils/app_theme.dart';

class PaymentFormScreen extends StatefulWidget {
  final DateTime selectedDate;

  const PaymentFormScreen({Key? key, required this.selectedDate})
    : super(key: key);

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCollaboratorId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Salvar pagamento
  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final activityProvider = Provider.of<ActivityProvider>(
        context,
        listen: false,
      );

      // Converter valor do campo
      final double amount = double.parse(
        _amountController.text
            .replaceAll(',', '.')
            .replaceAll('R\$', '')
            .trim(),
      );

      await activityProvider.addPayment(
        date: widget.selectedDate,
        amount: amount,
        collaboratorId: _selectedCollaboratorId!,
        description:
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pagamento registrado com sucesso!'),
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
    final activityProvider = Provider.of<ActivityProvider>(context);
    final collaborators = activityProvider.collaborators;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Pagamento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          Icon(
                            Icons.calendar_today,
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Data: ${widget.selectedDate.day.toString().padLeft(2, '0')}/${widget.selectedDate.month.toString().padLeft(2, '0')}/${widget.selectedDate.year}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppTheme.primaryDarkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seleu00e7u00e3o de colaborador
                  if (collaborators.isEmpty)
                    Card(
                      color: AppTheme.warningYellow.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: AppTheme.warningYellow,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sem colaboradores',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Vocu00ea precisa cadastrar ao menos um colaborador primeiro.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showAddCollaboratorDialog(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.warningYellow,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Adicionar Colaborador'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selecione o Colaborador',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _showAddCollaboratorDialog(context);
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Novo'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? AppTheme.darkSurface
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isDarkMode
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: collaborators.length,
                              separatorBuilder:
                                  (context, index) => Divider(
                                    height: 1,
                                    color:
                                        isDarkMode
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200,
                                  ),
                              itemBuilder: (context, index) {
                                final collaborator = collaborators[index];
                                final isSelected =
                                    collaborator.id == _selectedCollaboratorId;

                                return RadioListTile<String>(
                                  title: Text(
                                    collaborator.name,
                                    style: TextStyle(
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Diu00e1ria: R\$ ${collaborator.dailyRate.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          isDarkMode
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade700,
                                    ),
                                  ),
                                  value: collaborator.id,
                                  groupValue: _selectedCollaboratorId,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCollaboratorId = value;
                                      // Pre-preencher com o valor da diu00e1ria
                                      _amountController.text = collaborator
                                          .dailyRate
                                          .toStringAsFixed(2);
                                    });
                                  },
                                  activeColor: AppTheme.primaryGreen,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Valor do pagamento
                  Text(
                    'Valor do Pagamento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Valor (R\$)',
                      hintText: 'Ex: 150,00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                      filled: true,
                      fillColor:
                          isDarkMode
                              ? Colors.grey.shade800.withOpacity(0.3)
                              : Colors.grey.shade50,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe um valor';
                      }
                      try {
                        double.parse(value.replaceAll(',', '.'));
                        return null;
                      } catch (e) {
                        return 'Valor invu00e1lido';
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Descriu00e7u00e3o ou observau00e7u00f5es
                  Text(
                    'Descriu00e7u00e3o (opcional)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Observau00e7u00f5es',
                      hintText: 'Ex: Pagamento de diu00e1ria extra',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode
                              ? Colors.grey.shade800.withOpacity(0.3)
                              : Colors.grey.shade50,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Botu00e3o de salvar
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          (_isSubmitting || _selectedCollaboratorId == null)
                              ? null
                              : _savePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                              : Text(
                                _selectedCollaboratorId == null
                                    ? 'Selecione um colaborador'
                                    : 'Registrar Pagamento',
                                style: const TextStyle(
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
      ),
    );
  }

  // Diu00e1logo para adicionar novo colaborador
  void _showAddCollaboratorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final rateController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Novo Colaborador',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Colaborador',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe o nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: rateController,
                      decoration: InputDecoration(
                        labelText: 'Valor da Diu00e1ria (R\$)',
                        hintText: 'Ex: 100,00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, informe o valor da diu00e1ria';
                        }
                        try {
                          double.parse(value.replaceAll(',', '.'));
                          return null;
                        } catch (e) {
                          return 'Valor invu00e1lido';
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final name = nameController.text.trim();
                            final rate = double.parse(
                              rateController.text.replaceAll(',', '.'),
                            );

                            // Adicionar colaborador
                            final provider = Provider.of<ActivityProvider>(
                              context,
                              listen: false,
                            );
                            await provider.addCollaborator(name, rate);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Colaborador adicionado com sucesso!',
                                  ),
                                  backgroundColor: AppTheme.successGreen,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Adicionar Colaborador',
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
}
