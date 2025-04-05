import 'package:flutter/material.dart';
import '../../../../utils/app_theme.dart';

class Alerts extends StatelessWidget {
  final List<String> alerts;

  const Alerts({Key? key, required this.alerts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
    );
  }
}
