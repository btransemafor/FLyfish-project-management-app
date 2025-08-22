import 'package:to_do/features/auth/domain/entities/user_entity.dart';

class ProjectMemberEntity {
  final String id; 
  final String role; 
  final String projectId;
  final String name; 
  final String phone; 
  final String email; 
  final DateTime? birthDay; 
  final String avatar; 

  ProjectMemberEntity({
    required this.id,
    required this.role,
    required this.projectId,
    required this.avatar, 
    this.birthDay, 
    required this.email, 
    required this.name, 
    required this.phone
  });
}
