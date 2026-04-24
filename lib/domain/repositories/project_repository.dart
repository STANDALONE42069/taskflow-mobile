import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjects();
  Future<ProjectEntity> createProject(ProjectEntity project);
  Future<ProjectEntity> updateProject(ProjectEntity project);
  Future<void> deleteProject(int projectId);
}