import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/projects/domain/entities/project_member_entity.dart';
import 'package:to_do/features/projects/domain/repository/project_repository.dart';

class FetchMemberByProjectUc {
  final ProjectRepository _repo; 
  const FetchMemberByProjectUc(this._repo); 
  Future<List<ProjectMemberEntity>> execute(String projectId) async {
    return await _repo.fetchMemberByProject(projectId); 
  }
}