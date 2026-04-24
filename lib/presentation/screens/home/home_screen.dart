import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/project_provider.dart';
import '../../widgets/task_card.dart';
import '../../widgets/project_card.dart';
import '../../../domain/entities/task.dart';
import '../tasks/tasks_screen.dart';
import '../projects/projects_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskProvider.notifier).loadTasks();
      ref.read(projectProvider.notifier).loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final projectState = ref.watch(projectProvider);
    final isDark = ref.watch(themeProvider);

    final pages = [
      _DashboardPage(taskState: taskState, projectState: projectState),
      const TasksFullPage(),     
      const ProjectsFullPage(),  
      const ProfileFullPage(),   
    ];

    return Theme(
      data: isDark ? _darkTheme() : Theme.of(context),
      child: Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }
}

class _DashboardPage extends ConsumerWidget {
  final dynamic taskState;
  final dynamic projectState;

  const _DashboardPage(
      {required this.taskState, required this.projectState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final tasks = taskState.tasks as List<TaskEntity>;
    final todoCount =
        tasks.where((t) => t.status == TaskStatus.todo).length;
    final inProgressCount =
        tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final doneCount =
        tasks.where((t) => t.status == TaskStatus.done).length;
    final overdueTasks = tasks
        .where((t) =>
            t.dueDate != null &&
            t.dueDate!.isBefore(DateTime.now()) &&
            t.status != TaskStatus.done)
        .toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good ${_greeting()},',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.fullName.split(' ').first ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            Colors.white.withOpacity(0.2),
                        child: Text(
                          (user?.fullName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _StatChip(
                          label: 'To Do',
                          value: todoCount,
                          color: Colors.white70),
                      const SizedBox(width: 10),
                      _StatChip(
                          label: 'In Progress',
                          value: inProgressCount,
                          color: Colors.amberAccent),
                      const SizedBox(width: 10),
                      _StatChip(
                          label: 'Done',
                          value: doneCount,
                          color: Colors.greenAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          if (overdueTasks.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${overdueTasks.length} task${overdueTasks.length > 1 ? 's' : ''} overdue',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (overdueTasks.isNotEmpty)
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Tasks',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: taskState.isLoading
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  )
                : tasks.isEmpty
                    ? SliverToBoxAdapter(
                        child: _EmptyState(
                          icon: Icons.assignment_outlined,
                          message:
                              'No tasks yet.\nTap + to create one.',
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = tasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () => context.push(
                                  '/tasks/edit',
                                  extra: task),
                              onDelete: () => ref
                                  .read(taskProvider.notifier)
                                  .deleteTask(task.id!),
                              onStatusChange: (status) {
                                ref
                                    .read(taskProvider.notifier)
                                    .updateTask(
                                        task.copyWith(status: status));
                              },
                            );
                          },
                          childCount: tasks.take(5).length,
                        ),
                      ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Projects',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all',
                        style: TextStyle(
                            color: AppColors.primary, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: projectState.projects.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptyState(
                      icon: Icons.folder_outlined,
                      message: 'No projects yet.',
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project =
                            projectState.projects[index];
                        return ProjectCard(
                          project: project,
                          onTap: () => context.push(
                              '/projects/detail',
                              extra: project),
                          onDelete: () => ref
                              .read(projectProvider.notifier)
                              .deleteProject(project.id!),
                        );
                      },
                      childCount:
                          projectState.projects.take(3).length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState(
      {required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textHint, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav(
      {required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

ThemeData _darkTheme() => ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight),
    );