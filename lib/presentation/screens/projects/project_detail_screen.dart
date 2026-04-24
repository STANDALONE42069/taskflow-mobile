import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final ProjectEntity project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskProvider.notifier).loadTasks(projectId: widget.project.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final project = widget.project;
    final color =
        Color(int.parse(project.colorHex.replaceFirst('#', '0xFF')));

    final tasks = taskState.tasks;
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final progress = tasks.isEmpty ? 0.0 : done / tasks.length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            backgroundColor: color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                project.name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_task, color: Colors.white),
                onPressed: () =>
                    context.push('/tasks/new', extra: project.id),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (project.description != null) ...[
                    Text(
                      project.description!,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progress',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: color)),
                            Text(
                              '$done / ${tasks.length} tasks',
                              style: TextStyle(color: color, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearPercentIndicator(
                          padding: EdgeInsets.zero,
                          percent: progress.clamp(0.0, 1.0),
                          lineHeight: 10,
                          backgroundColor: color.withOpacity(0.15),
                          progressColor: color,
                          barRadius: const Radius.circular(10),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(progress * 100).toInt()}% complete',
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('Tasks',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: taskState.isLoading
                ? const SliverToBoxAdapter(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                  )
                : tasks.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Text('No tasks in this project.',
                              style: TextStyle(color: AppColors.textHint)),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = tasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () =>
                                  context.push('/tasks/edit', extra: task),
                              onDelete: () => ref
                                  .read(taskProvider.notifier)
                                  .deleteTask(task.id!),
                              onStatusChange: (status) {
                                ref
                                    .read(taskProvider.notifier)
                                    .updateTask(task.copyWith(status: status));
                              },
                            );
                          },
                          childCount: tasks.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}