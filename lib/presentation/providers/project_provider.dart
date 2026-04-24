import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/projects/get_projects_usecase.dart';
import '../../domain/usecases/projects/create_project_usecase.dart';
import '../../domain/usecases/projects/delete_project_usecase.dart';

class ProjectState {
  final List<ProjectEntity> projects;
  final bool isLoading;
  final String? error;

  const ProjectState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
  });

  ProjectState copyWith({
    List<ProjectEntity>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectState> {
  final GetProjectsUseCase _getProjectsUseCase;
  final CreateProjectUseCase _createProjectUseCase;
  final DeleteProjectUseCase _deleteProjectUseCase;

  ProjectNotifier(
    this._getProjectsUseCase,
    this._createProjectUseCase,
    this._deleteProjectUseCase,
  ) : super(const ProjectState());

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final projects = await _getProjectsUseCase();
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createProject(ProjectEntity project) async {
    try {
      final created = await _createProjectUseCase(project);
      state = state.copyWith(projects: [...state.projects, created]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteProject(int projectId) async {
    try {
      await _deleteProjectUseCase(projectId);
      state = state.copyWith(
          projects: state.projects.where((p) => p.id != projectId).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final projectProvider =
    StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  return ProjectNotifier(
    sl<GetProjectsUseCase>(),
    sl<CreateProjectUseCase>(),
    sl<DeleteProjectUseCase>(),
  );
});

final themeProvider = StateProvider<bool>((ref) => false);