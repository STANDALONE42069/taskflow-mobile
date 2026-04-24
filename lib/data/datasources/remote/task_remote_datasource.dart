import '../../../core/network/api_client.dart';
import '../../models/task_model.dart';
import '../../../domain/entities/task.dart';

class TaskRemoteDataSource {
  final ApiClient apiClient;

  TaskRemoteDataSource(this.apiClient);

  Future<List<TaskModel>> getTasks({int? projectId}) async {
    final params = projectId != null ? {'projectId': projectId} : null;
    final response = await apiClient.dio.get('/tasks', queryParameters: params);
    return (response.data as List).map((t) => TaskModel.fromJson(t)).toList();
  }

  Future<TaskModel> createTask(TaskEntity task) async {
    final model = task as TaskModel;
    final response = await apiClient.dio.post('/tasks', data: model.toJson());
    return TaskModel.fromJson(response.data);
  }

  Future<TaskModel> updateTask(TaskEntity task) async {
    final model = task as TaskModel;
    final response =
        await apiClient.dio.put('/tasks/${task.id}', data: model.toJson());
    return TaskModel.fromJson(response.data);
  }

  Future<void> deleteTask(int taskId) async {
    await apiClient.dio.delete('/tasks/$taskId');
  }
}