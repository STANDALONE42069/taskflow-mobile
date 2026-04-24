import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/task.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<TaskStatus> onStatusChange;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.done;
    final isOverdue = task.dueDate != null &&
        DateFormatter.isOverdue(task.dueDate!) &&
        !isDone;

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.35,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(16)),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverdue
                  ? AppColors.error.withOpacity(0.4)
                  : task.isCollaborative
                      ? AppColors.accent.withOpacity(0.4)
                      : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => onStatusChange(
                    isDone ? TaskStatus.todo : TaskStatus.done),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color:
                          isDone ? AppColors.primary : AppColors.textHint,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check,
                          size: 13, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isDone
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (task.isCollaborative)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.accent.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 11, color: AppColors.accent),
                                const SizedBox(width: 3),
                                Text(
                                  'Collab',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        PriorityBadge(priority: task.priority),
                        const Spacer(),
                        if (task.dueDate != null)
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: isOverdue
                                    ? AppColors.error
                                    : AppColors.textHint,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.format(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isOverdue
                                      ? AppColors.error
                                      : AppColors.textHint,
                                  fontWeight: isOverdue
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    if (task.assignedToName != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 9,
                            backgroundColor: AppColors.primarySurface,
                            child: Text(
                              task.assignedToName![0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            task.isCollaborative
                                ? 'Assigned to ${task.assignedToName}'
                                : task.assignedToName!,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                          if (task.isCollaborative &&
                              task.creatorName != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '· by ${task.creatorName}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}