import '../../entities/task.dart';
import '../../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;
  UpdateTaskUseCase(this.repository);

  Future<TaskEntity> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}