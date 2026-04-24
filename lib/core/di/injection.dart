import 'package:get_it/get_it.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/task_remote_datasource.dart';
import '../../data/datasources/remote/project_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/tasks/get_tasks_usecase.dart';
import '../../domain/usecases/tasks/create_task_usecase.dart';
import '../../domain/usecases/tasks/update_task_usecase.dart';
import '../../domain/usecases/tasks/delete_task_usecase.dart';
import '../../domain/usecases/projects/get_projects_usecase.dart';
import '../../domain/usecases/projects/create_project_usecase.dart';
import '../../domain/usecases/projects/delete_project_usecase.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(sl<ApiClient>()));
  sl.registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSource(sl<ApiClient>()));
  sl.registerLazySingleton<ProjectRemoteDataSource>(
      () => ProjectRemoteDataSource(sl<ApiClient>()));


  final authRepo = AuthRepositoryImpl(sl<AuthRemoteDataSource>());
  sl.registerLazySingleton<AuthRepository>(() => authRepo);
  sl.registerLazySingleton<AuthRepositoryImpl>(() => authRepo);

  final taskRepo = TaskRepositoryImpl(sl<TaskRemoteDataSource>());
  sl.registerLazySingleton<TaskRepository>(() => taskRepo);
  sl.registerLazySingleton<TaskRepositoryImpl>(() => taskRepo);

  final projectRepo = ProjectRepositoryImpl(sl<ProjectRemoteDataSource>());
  sl.registerLazySingleton<ProjectRepository>(() => projectRepo);
  sl.registerLazySingleton<ProjectRepositoryImpl>(() => projectRepo);

  sl.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton<GetTasksUseCase>(
      () => GetTasksUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton<CreateTaskUseCase>(
      () => CreateTaskUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton<UpdateTaskUseCase>(
      () => UpdateTaskUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton<DeleteTaskUseCase>(
      () => DeleteTaskUseCase(sl<TaskRepository>()));

  sl.registerLazySingleton<GetProjectsUseCase>(
      () => GetProjectsUseCase(sl<ProjectRepository>()));
  sl.registerLazySingleton<CreateProjectUseCase>(
      () => CreateProjectUseCase(sl<ProjectRepository>()));
  sl.registerLazySingleton<DeleteProjectUseCase>(
      () => DeleteProjectUseCase(sl<ProjectRepository>()));
}