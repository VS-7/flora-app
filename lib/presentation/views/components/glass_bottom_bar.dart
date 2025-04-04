import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../utils/app_theme.dart';

class GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Widget? floatingActionButton;

  const GlassBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
            border: Border(
              top: BorderSide(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildNavItem(
                      context: context,
                      index: 0,
                      icon: Icons.calendar_today,
                      label: 'Calendário',
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context: context,
                      index: 1,
                      icon: Icons.bar_chart,
                      label: 'Relatório',
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context: context,
                      index: 2,
                      icon: Icons.person_add,
                      label: 'Cadastro',
                    ),
                  ),
                ],
              ),
              if (floatingActionButton != null)
                Positioned(top: -20, child: floatingActionButton!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color:
                isSelected
                    ? AppTheme.primaryGreen
                    : isDarkMode
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color:
                  isSelected
                      ? AppTheme.primaryGreen
                      : isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
