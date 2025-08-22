import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/projects/domain/entities/project_member_entity.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> fetchListProject([bool? isLeader]);
  Future<List<ProjectMemberEntity>> fetchMemberByProject(String projectId); 
   Future<ProjectEntity> createProject(
    String name,
    String description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String leader_id,
  );

  Future<String> addMemberIntoProject(String user_id, String project_id); 
  Future<ProjectEntity> fetchProjectById(String project_id); 
}