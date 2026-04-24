import '../../entities/task.dart';
import '../../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;
  GetTasksUseCase(this.repository);

  Future<List<TaskEntity>> call({int? projectId}) {
    return repository.getTasks(projectId: projectId);
  }
}