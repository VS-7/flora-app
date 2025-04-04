import 'package:flutter/material.dart';
import '../../../domain/models/activity_model.dart';
import '../../../utils/app_theme.dart';

class ActivityListItem extends StatelessWidget {
  final Activity activity;

  const ActivityListItem({Key? key, required this.activity}) : super(key: key);

  // Ícone correspondente ao tipo de atividade
  IconData getActivityIcon() {
    switch (activity.type) {
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

  // Cor correspondente ao tipo de atividade
  Color getActivityColor() {
    switch (activity.type) {
      case ActivityType.harvest:
        return Colors.orange;
      case ActivityType.pruning:
        return Colors.red;
      case ActivityType.fertilize:
        return AppTheme.primaryGreen;
      case ActivityType.spray:
        return Colors.teal;
      case ActivityType.watering:
        return Colors.blue;
      case ActivityType.weeding:
        return Colors.lime;
      case ActivityType.planting:
        return AppTheme.primaryDarkGreen;
      case ActivityType.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activityColor = getActivityColor();
    final activityIcon = getActivityIcon();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Mostrar detalhes da atividade
          showDialog(
            context: context,
            builder: (context) => ActivityDetailsDialog(activity: activity),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ícone da atividade
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: activityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(activityIcon, color: activityColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Informações da atividade
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.type.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Custo (se houver)
              if (activity.cost != null)
                Text(
                  'R\$ ${activity.cost!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.greenAccent : Colors.green[800],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityDetailsDialog extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsDialog({Key? key, required this.activity})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        activity.description,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            context,
            'Tipo:',
            activity.type.displayName,
            Icons.category,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            'Data:',
            '${activity.date.day.toString().padLeft(2, '0')}/${activity.date.month.toString().padLeft(2, '0')}/${activity.date.year}',
            Icons.calendar_today,
          ),
          if (activity.cost != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              'Custo:',
              'R\$ ${activity.cost!.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
          ],
          if (activity.areaInHectares != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              'Área:',
              '${activity.areaInHectares!.toStringAsFixed(2)} ha',
              Icons.straighten,
            ),
          ],
          if (activity.quantityInBags != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              'Quantidade:',
              '${activity.quantityInBags} sacas',
              Icons.inventory_2,
            ),
          ],
          if (activity.notes != null && activity.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Observações:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                activity.notes!,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
