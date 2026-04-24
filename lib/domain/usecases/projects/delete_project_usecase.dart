import '../../repositories/project_repository.dart';

class DeleteProjectUseCase {
  final ProjectRepository repository;
  DeleteProjectUseCase(this.repository);

  Future<void> call(int projectId) {
    return repository.deleteProject(projectId);
  }
}