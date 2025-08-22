import 'package:equatable/equatable.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String priority;
  final DateTime? dueDate;
  final String status;
  final List<UserEntity> assignees;
  final UserEntity creator;
  final String projectId; 

  const TaskEntity({
    required this.id,
    required this.description,
    required this.title,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.assignees = const [],
    required this.creator,
    required this.projectId 

  });

  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      projectId: json['projectId'] ?? '',
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Low',
      status: json['status'] ?? 'Not Started',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      assignees: (json['assignees'] as List<dynamic>?)
              ?.map((e) => UserEntity.fromJson(e))
              .toList() ??
          [],
      creator: UserEntity.fromJson(json['creator'] ?? {}),
    );
  }


/*   Map<String, dynamic> diff(TaskEntity others) {
    final updateFields = <String, dynamic>{};
    if (title != others.title) {
      updateFields['title'] = others.title;
    }
    if (description != others.description) {
      updateFields['description'] = others.description;
    }
    if (status != others.status) {
      updateFields['status'] = others.status;
    }
    if (priority != others.priority) {
      updateFields['priority'] = others.priority;
    }
    if (dueDate != others.dueDate) {
      updateFields['dueDate'] = others.dueDate?.toIso8601String();
    }
    return updateFields;
  } */

   Map<String, dynamic> diff(Map<String,dynamic> others) {
    final updateFields = <String, dynamic>{};
    if (title != others['title']) {
      updateFields['title'] = others['title'];
    }
    if (description != others['description']) {
      updateFields['description'] = others['description'];
    }
    if (status != others['status']) {
      updateFields['status'] = others['status'];
    }
    if (priority != others['priority']) {
      updateFields['priority'] = others['priority'];
    }
    if (dueDate != others['dueDate']) {
      updateFields['dueDate'] = others['dueDate'];
    }
    return updateFields;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        status,
        dueDate,
        assignees,
        creator,
      ];
}