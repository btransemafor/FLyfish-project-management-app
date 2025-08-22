import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required super.projectId,
    required super.assignees,
    required super.creator,
    required super.description,
    required super.dueDate,
    required super.id,
    required super.priority,
    required super.status,
    required super.title,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      projectId: json['projectId'] ?? '',
      assignees: (json['assignees'] as List<dynamic>? ?? [])
          .map((item) => UserEntity.fromJson(item))
          .toList(),
      creator: json['creator'] != null
          ? UserEntity.fromJson(json['creator'] as Map<String, dynamic>)
          : UserEntity.empty(), //  fallback để tránh lỗi
      description: json['description'] ?? '',
      dueDate:
          json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      id: json['id'] ?? '',
      priority: json['priority'] ?? 'Low',
      status: json['status'] ?? 'Not Started',
      title: json['title'] ?? '',
    );
  }
}
