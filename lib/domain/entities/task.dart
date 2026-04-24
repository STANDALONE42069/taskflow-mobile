enum TaskStatus { todo, inProgress, done, cancelled }
enum TaskPriority { low, medium, high, urgent }

class TaskEntity {
  final int? id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final int projectId;
  final int? creatorId;
  final String? creatorName;
  final int? assignedToId;
  final String? assignedToName;
  final bool isCollaborative;
  final DateTime createdAt;

  const TaskEntity({
    this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.projectId,
    this.creatorId,
    this.creatorName,
    this.assignedToId,
    this.assignedToName,
    this.isCollaborative = false,
    required this.createdAt,
  });

  TaskEntity copyWith({
    int? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    int? projectId,
    int? creatorId,
    String? creatorName,
    int? assignedToId,
    String? assignedToName,
    bool? isCollaborative,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      projectId: projectId ?? this.projectId,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      isCollaborative: isCollaborative ?? this.isCollaborative,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}