import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../domain/models/activity_model.dart';
import '../../providers/activity_provider.dart';
import '../../providers/user_provider.dart';
import '../screens/activity_form_screen.dart';
import '../screens/payment_form_screen.dart';
import '../widgets/home/activity_list_widget.dart';
import '../../../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.week;

    // Carregar dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final activityProvider = Provider.of<ActivityProvider>(
        context,
        listen: false,
      );

      userProvider.initialize();
      activityProvider.initialize();

      // Verificar se o usuário está registrado
    });
  }

  // Método para navegar para a tela de adicionar atividade
  void _navigateToAddActivity() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityFormScreen(selectedDate: _selectedDay),
      ),
    );
  }

  // Método para navegar para a tela de registrar pagamento
  void _navigateToAddPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentFormScreen(selectedDate: _selectedDay),
      ),
    );
  }

  // Selecionar item do menu inferior
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);
    final selectedDayActivities = activityProvider.getActivitiesForDay(
      _selectedDay,
    );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Lista de possíveis alertas
    List<String> alerts = [];
    if (activityProvider.needsAlert(ActivityType.fertilize, 30)) {
      alerts.add("Última adubação foi há mais de 30 dias");
    }
    if (activityProvider.needsAlert(ActivityType.pruning, 180)) {
      alerts.add("Última poda foi há mais de 6 meses");
    }

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Alertas (se houver)
            if (alerts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: AppTheme.warningYellow.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      color: AppTheme.warningYellow,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        alerts.first,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (alerts.length > 1)
                      Chip(
                        backgroundColor: AppTheme.warningYellow,
                        label: Text(
                          '+${alerts.length - 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),

            // Calendário
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TableCalendar<Activity>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    tableBorder: TableBorder(
                      bottom: BorderSide(
                        color:
                            isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    titleTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    headerPadding: const EdgeInsets.symmetric(vertical: 16),
                    formatButtonDecoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: isDarkMode ? Colors.white : AppTheme.primaryGreen,
                      fontSize: 13,
                    ),
                  ),
                  eventLoader: (day) {
                    return activityProvider.getActivitiesForDay(day);
                  },
                ),
              ),
            ),

            // Lista de atividades do dia selecionado
            ActivityList(
              activities: selectedDayActivities,
              onAddActivity: _navigateToAddActivity,
            ),
          ],
        ),
      ),
    );
  }

  // Mostrar menu de ações
  void _showActionSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      'Adicionar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.event_note,
                          label: 'Atividade',
                          color: AppTheme.primaryGreen,
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToAddActivity();
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.payments_outlined,
                          label: 'Pagamento',
                          color: AppTheme.earthBrown,
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToAddPayment();
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.person_add_outlined,
                          label: 'Colaborador',
                          color: AppTheme.skyBlue,
                          onTap: () {
                            Navigator.pop(context);
                            _showCollaboratorDialog();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // Construir botão de ação
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo para adicionar colaborador
  void _showCollaboratorDialog() {
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
