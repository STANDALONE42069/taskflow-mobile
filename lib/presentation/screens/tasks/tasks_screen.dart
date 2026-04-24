import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import '../../../domain/entities/task.dart';

class TasksFullPage extends ConsumerStatefulWidget {
  const TasksFullPage({super.key});

  @override
  ConsumerState<TasksFullPage> createState() => _TasksFullPageState();
}

class _TasksFullPageState extends ConsumerState<TasksFullPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(taskProvider).tasks.isEmpty) {
        ref.read(taskProvider.notifier).loadTasks();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => context.push('/tasks/new'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'To Do (${taskState.todoTasks.length})'),
            Tab(text: 'In Progress (${taskState.inProgressTasks.length})'),
            Tab(text: 'Done (${taskState.doneTasks.length})'),
          ],
        ),
      ),
      body: taskState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _TaskList(tasks: taskState.todoTasks),
                _TaskList(tasks: taskState.inProgressTasks),
                _TaskList(tasks: taskState.doneTasks),
              ],
            ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  final List<TaskEntity> tasks;
  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text('No tasks here',
                style: TextStyle(color: AppColors.textHint)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => context.push('/tasks/edit', extra: task),
          onDelete: () =>
              ref.read(taskProvider.notifier).deleteTask(task.id!),
          onStatusChange: (status) {
            ref
                .read(taskProvider.notifier)
                .updateTask(task.copyWith(status: status));
          },
        );
      },
    );
  }
}