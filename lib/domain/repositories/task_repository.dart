import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks({int? projectId});
  Future<TaskEntity> createTask(TaskEntity task);
  Future<TaskEntity> updateTask(TaskEntity task);
  Future<void> deleteTask(int taskId);
}