import '../../../core/network/api_client.dart';
import '../../models/project_model.dart';
import '../../../domain/entities/project.dart';

class ProjectRemoteDataSource {
  final ApiClient apiClient;

  ProjectRemoteDataSource(this.apiClient);

  Future<List<ProjectModel>> getProjects() async {
    final response = await apiClient.dio.get('/projects');
    return (response.data as List)
        .map((p) => ProjectModel.fromJson(p))
        .toList();
  }

  Future<ProjectModel> createProject(ProjectEntity project) async {
    final model = project as ProjectModel;
    final response =
        await apiClient.dio.post('/projects', data: model.toJson());
    return ProjectModel.fromJson(response.data);
  }

  Future<ProjectModel> updateProject(ProjectEntity project) async {
    final model = project as ProjectModel;
    final response =
        await apiClient.dio.put('/projects/${project.id}', data: model.toJson());
    return ProjectModel.fromJson(response.data);
  }

  Future<void> deleteProject(int projectId) async {
    await apiClient.dio.delete('/projects/$projectId');
  }
}