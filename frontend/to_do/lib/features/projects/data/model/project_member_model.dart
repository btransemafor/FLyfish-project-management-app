// data/models/project_member_model.dart
import 'package:to_do/features/projects/domain/entities/project_member_entity.dart';

class ProjectMemberModel extends ProjectMemberEntity{

  ProjectMemberModel({
    required super.id, 
    required super.projectId, 
    required super.role, 
    required super.avatar, 
    super.birthDay, 
    required super.email, 
    required super.name,
    required super.phone
  });

  // From JSON
  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['user_id'],
      projectId: json['project_id'],
      role: json['role'] ?? 'member',
      avatar: json['avatar'] ?? '', 
      email: json['email'] ?? '', 
      phone: json['phone'] ?? '', 
      birthDay: DateTime.parse(json['birthday']) ?? DateTime(1970, 1, 1), 
      name: json['fullname'] ?? ''
    );
  }

  // To JSON
}
