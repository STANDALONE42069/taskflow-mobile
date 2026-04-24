import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/remote/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TaskEntity>> getTasks({int? projectId}) {
    return remoteDataSource.getTasks(projectId: projectId);
  }

  @override
  Future<TaskEntity> createTask(TaskEntity task) {
    return remoteDataSource.createTask(task);
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) {
    return remoteDataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(int taskId) {
    return remoteDataSource.deleteTask(taskId);
  }
}