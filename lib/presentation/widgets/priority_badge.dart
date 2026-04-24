import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/task.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final config = _config[priority]!;

    final Color color = config['color'] as Color;
    final String label = config['label'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static final Map<TaskPriority, Map<String, dynamic>> _config = {
    TaskPriority.low: {
      'color': AppColors.priorityLow,
      'label': 'Low'
    },
    TaskPriority.medium: {
      'color': AppColors.priorityMedium,
      'label': 'Medium'
    },
    TaskPriority.high: {
      'color': AppColors.priorityHigh,
      'label': 'High'
    },
    TaskPriority.urgent: {
      'color': AppColors.priorityUrgent,
      'label': 'Urgent'
    },
  };
}