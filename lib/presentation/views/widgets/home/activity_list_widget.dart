import 'package:flutter/material.dart';
import '../../../../domain/models/activity_model.dart';
import '../../../../utils/app_theme.dart';
import '../../screens/activity_list_item.dart';

class ActivityList extends StatelessWidget {
  final List<Activity> activities;
  final Function() onAddActivity;

  const ActivityList({
    Key? key,
    required this.activities,
    required this.onAddActivity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        child:
            activities.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 64,
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma atividade registrada',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar'),
                        onPressed: onAddActivity,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  itemCount: activities.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return ActivityListItem(activity: activities[index]);
                  },
                ),
      ),
    );
  }
}
