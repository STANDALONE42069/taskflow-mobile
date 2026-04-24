import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../core/services/notification_service.dart'; 
import '../../domain/entities/task.dart';
import '../../domain/usecases/tasks/get_tasks_usecase.dart';
import '../../domain/usecases/tasks/create_task_usecase.dart';
import '../../domain/usecases/tasks/update_task_usecase.dart';
import '../../domain/usecases/tasks/delete_task_usecase.dart';

class TaskState {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final String? error;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });

  TaskState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<TaskEntity> get todoTasks =>
      tasks.where((t) => t.status == TaskStatus.todo).toList();
  List<TaskEntity> get inProgressTasks =>
      tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<TaskEntity> get doneTasks =>
      tasks.where((t) => t.status == TaskStatus.done).toList();
}

class TaskNotifier extends StateNotifier<TaskState> {
  final GetTasksUseCase _getTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final NotificationService _notifs = NotificationService();

  TaskNotifier(
    this._getTasksUseCase,
    this._createTaskUseCase,
    this._updateTaskUseCase,
    this._deleteTaskUseCase,
  ) : super(const TaskState());

  Future<void> loadTasks({int? projectId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _getTasksUseCase(projectId: projectId);
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createTask(TaskEntity task) async {
    try {
      final created = await _createTaskUseCase(task);
      state = state.copyWith(tasks: [...state.tasks, created]);

      if (created.isCollaborative && created.assignedToName != null) {
        await _notifs.showTaskAssignedNotification(
          created.title,
          created.assignedToName!,
        );
      }

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

Future<bool> updateTask(TaskEntity task) async {
  TaskStatus? oldStatus;
  try {
    final oldTask = state.tasks.firstWhere((t) => t.id == task.id);
    oldStatus = oldTask.status;
  } catch (_) {
    oldStatus = null;
  }

  try {
    final updated = await _updateTaskUseCase(task);
    final newList =
        state.tasks.map((t) => t.id == task.id ? updated : t).toList();
    state = state.copyWith(tasks: newList);

    final justCompleted = oldStatus != null &&
        oldStatus != TaskStatus.done &&
        updated.status == TaskStatus.done;
    if (justCompleted) {
      await _notifs.showTaskDoneNotification(updated.title);
    }

    return true;
  } catch (e) {
    state = state.copyWith(error: e.toString());
    return false;
  }
}

  Future<bool> deleteTask(int taskId) async {
    try {
      await _deleteTaskUseCase(taskId);
      state = state.copyWith(
          tasks: state.tasks.where((t) => t.id != taskId).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final taskProvider =
    StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(
    sl<GetTasksUseCase>(),
    sl<CreateTaskUseCase>(),
    sl<UpdateTaskUseCase>(),
    sl<DeleteTaskUseCase>(),
  );
});