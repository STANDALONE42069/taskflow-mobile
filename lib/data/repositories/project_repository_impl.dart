import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/remote/project_remote_datasource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProjectEntity>> getProjects() {
    return remoteDataSource.getProjects();
  }

  @override
  Future<ProjectEntity> createProject(ProjectEntity project) {
    return remoteDataSource.createProject(project);
  }

  @override
  Future<ProjectEntity> updateProject(ProjectEntity project) {
    return remoteDataSource.updateProject(project);
  }

  @override
  Future<void> deleteProject(int projectId) {
    return remoteDataSource.deleteProject(projectId);
  }
}