class ProjectEntity {
  final int? id;
  final String name;
  final String? description;
  final String colorHex;
  final int ownerId;
  final DateTime createdAt;
  final int taskCount;
  final int completedCount;

  const ProjectEntity({
    this.id,
    required this.name,
    this.description,
    required this.colorHex,
    required this.ownerId,
    required this.createdAt,
    this.taskCount = 0,
    this.completedCount = 0,
  });

  double get progress =>
      taskCount == 0 ? 0.0 : completedCount / taskCount;
}