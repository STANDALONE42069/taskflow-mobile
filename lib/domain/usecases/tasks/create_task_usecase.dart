import '../../entities/task.dart';
import '../../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;
  CreateTaskUseCase(this.repository);

  Future<TaskEntity> call(TaskEntity task) {
    return repository.createTask(task);
  }
}