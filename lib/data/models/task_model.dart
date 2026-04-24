import '../../domain/entities/task.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    super.id,
    required super.title,
    super.description,
    required super.status,
    required super.priority,
    super.dueDate,
    required super.projectId,
    super.creatorId,
    super.creatorName,
    super.assignedToId,
    super.assignedToName,
    super.isCollaborative,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: _parseStatus(json['status']),
      priority: _parsePriority(json['priority']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      projectId: json['projectId'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      assignedToId: json['assignedToId'],
      assignedToName: json['assignedToName'],
      isCollaborative: json['isCollaborative'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': _statusToString(status),
      'priority': _priorityToString(priority),
      'dueDate': dueDate?.toIso8601String(),
      'projectId': projectId,
      'assignedToId': assignedToId,
    };
  }

  static String _statusToString(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo: return 'TODO';
      case TaskStatus.inProgress: return 'IN_PROGRESS'; 
      case TaskStatus.done: return 'DONE';
      case TaskStatus.cancelled: return 'CANCELLED';
    }
  }

  static String _priorityToString(TaskPriority p) {
    switch (p) {
      case TaskPriority.low: return 'LOW';
      case TaskPriority.medium: return 'MEDIUM';
      case TaskPriority.high: return 'HIGH';
      case TaskPriority.urgent: return 'URGENT';
    }
  }

  static TaskStatus _parseStatus(String? s) {
    switch (s?.toUpperCase()) {
      case 'IN_PROGRESS': return TaskStatus.inProgress;
      case 'DONE': return TaskStatus.done;
      case 'CANCELLED': return TaskStatus.cancelled;
      default: return TaskStatus.todo;
    }
  }

  static TaskPriority _parsePriority(String? p) {
    switch (p?.toUpperCase()) {
      case 'MEDIUM': return TaskPriority.medium;
      case 'HIGH': return TaskPriority.high;
      case 'URGENT': return TaskPriority.urgent;
      default: return TaskPriority.low;
    }
  }
}