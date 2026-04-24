import '../../domain/entities/project.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    super.id,
    required super.name,
    super.description,
    required super.colorHex,
    required super.ownerId,
    required super.createdAt,
    super.taskCount,
    super.completedCount,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      colorHex: json['colorHex'] ?? '#9B1B30',
      ownerId: json['ownerId'],
      createdAt: DateTime.parse(json['createdAt']),
      taskCount: json['taskCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'colorHex': colorHex,
    };
  }
}