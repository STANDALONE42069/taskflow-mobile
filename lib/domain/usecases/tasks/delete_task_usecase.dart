import '../../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;
  DeleteTaskUseCase(this.repository);

  Future<void> call(int taskId) {
    return repository.deleteTask(taskId);
  }
}