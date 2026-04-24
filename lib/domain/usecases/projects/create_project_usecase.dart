import '../../entities/project.dart';
import '../../repositories/project_repository.dart';

class CreateProjectUseCase {
  final ProjectRepository repository;
  CreateProjectUseCase(this.repository);

  Future<ProjectEntity> call(ProjectEntity project) {
    return repository.createProject(project);
  }
}