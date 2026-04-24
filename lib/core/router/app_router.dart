import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/tasks/task_form_screen.dart';
import '../../presentation/screens/projects/project_detail_screen.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/project.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/tasks/new',
      builder: (context, state) {
        return const TaskFormScreen();
      },
    ),
    GoRoute(
      path: '/tasks/edit',
      builder: (context, state) {
        final task = state.extra as TaskEntity;
        return TaskFormScreen(existingTask: task);
      },
    ),
    GoRoute(
      path: '/projects/detail',
      builder: (context, state) {
        final project = state.extra as ProjectEntity;
        return ProjectDetailScreen(project: project);
      },
    ),
  ],
);