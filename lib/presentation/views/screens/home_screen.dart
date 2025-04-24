import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/farm_provider.dart';
import '../../../presentation/providers/farm_activity_provider.dart';
import '../../../utils/app_theme.dart';
import '../../../domain/models/farm_activity_model.dart';
import 'farm_activity_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  late PageController _monthController;
  final List<DateTime> _visibleDates = [];

  @override
  void initState() {
    super.initState();
    _monthController = PageController(initialPage: 0);
    _generateDaysForMonth(DateTime.now());

    // Carregar atividades da data selecionada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadActivitiesForSelectedDate();
    });
  }

  @override
  void dispose() {
    _monthController.dispose();
    super.dispose();
  }

  void _generateDaysForMonth(DateTime month) {
    _visibleDates.clear();

    // Primeiro dia do mês
    final firstDayOfMonth = DateTime(month.year, month.month, 1);

    // Último dia do mês
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // Gerar todos os dias do mês
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      _visibleDates.add(DateTime(month.year, month.month, i));
    }
  }

  void _loadActivitiesForSelectedDate() {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final activityProvider = Provider.of<FarmActivityProvider>(
      context,
      listen: false,
    );

    if (farmProvider.currentFarm != null) {
      activityProvider.loadActivitiesByDate(_selectedDate);
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadActivitiesForSelectedDate();
  }

  void _onMonthChanged(DateTime month) {
    setState(() {
      _generateDaysForMonth(month);
    });
  }

  void _nextMonth() {
    final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    setState(() {
      _selectedDate = DateTime(nextMonth.year, nextMonth.month, 1);
      _generateDaysForMonth(nextMonth);
    });
    _loadActivitiesForSelectedDate();
  }

  void _previousMonth() {
    final prevMonth = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    setState(() {
      _selectedDate = DateTime(prevMonth.year, prevMonth.month, 1);
      _generateDaysForMonth(prevMonth);
    });
    _loadActivitiesForSelectedDate();
  }

  void _navigateToCreateActivity() {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    if (farmProvider.currentFarm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma fazenda primeiro')),
      );
      return;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) =>
                    FarmActivityFormScreen(preselectedDate: _selectedDate),
          ),
        )
        .then((_) {
          // Recarregar atividades quando voltar
          _loadActivitiesForSelectedDate();
        });
  }

  void _navigateToEditActivity(FarmActivity activity) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => FarmActivityFormScreen(activity: activity),
          ),
        )
        .then((_) {
          // Recarregar atividades quando voltar
          _loadActivitiesForSelectedDate();
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final activityProvider = Provider.of<FarmActivityProvider>(context);
    final farmProvider = Provider.of<FarmProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(
                      'MMMM, yyyy',
                      'pt_BR',
                    ).format(_selectedDate).toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Calendar Days
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                itemCount: _visibleDates.length,
                itemBuilder: (context, index) {
                  final date = _visibleDates[index];
                  final isSelected =
                      date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;

                  // Get day of week in Portuguese
                  final dayName =
                      DateFormat('E', 'pt_BR').format(date).toLowerCase();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => _onDateSelected(date),
                      child: Container(
                        width: 55,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? isDarkMode
                                      ? AppTheme.primaryDarkGreen
                                      : AppTheme.accentGreen
                                  : isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.day.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? isDarkMode
                                            ? AppTheme.accentGreen
                                            : AppTheme.primaryDarkGreen
                                        : isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            ),
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected
                                        ? isDarkMode
                                            ? AppTheme.accentGreen
                                            : AppTheme.primaryDarkGreen
                                        : isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Activities for selected date
            Expanded(
              child:
                  farmProvider.currentFarm == null
                      ? Center(
                        child: Text(
                          'Selecione uma fazenda para ver as atividades',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      )
                      : activityProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : activityProvider.activities.isEmpty
                      ? Center(
                        child: Text(
                          'Nenhuma atividade para ${DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDate)}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: activityProvider.activities.length,
                        itemBuilder: (context, index) {
                          final activity = activityProvider.activities[index];
                          return _buildActivityCard(
                            context,
                            activity,
                            isDarkMode,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
        onPressed: _navigateToCreateActivity,
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    FarmActivity activity,
    bool isDarkMode,
  ) {
    // Função para obter o ícone baseado no tipo de atividade
    IconData getActivityIcon(ActivityType type) {
      switch (type) {
        case ActivityType.planting:
          return Icons.grass;
        case ActivityType.irrigation:
          return Icons.water_drop;
        case ActivityType.fertilization:
          return Icons.compost;
        case ActivityType.pestControl:
          return Icons.bug_report;
        case ActivityType.pruning:
          return Icons.content_cut;
        case ActivityType.harvesting:
          return Icons.agriculture;
        case ActivityType.maintenance:
          return Icons.handyman;
        case ActivityType.other:
        default:
          return Icons.event_note;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
          child: Icon(
            getActivityIcon(activity.type),
            color: AppTheme.primaryGreen,
          ),
        ),
        title: Text(
          activity.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          activity.description,
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.white54 : Colors.black45,
        ),
        onTap: () => _navigateToEditActivity(activity),
      ),
    );
  }
}
