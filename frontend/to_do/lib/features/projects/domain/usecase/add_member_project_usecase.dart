import 'package:to_do/features/projects/domain/repository/project_repository.dart';

class AddMemberProjectUsecase {
  final ProjectRepository _repo; 
  const AddMemberProjectUsecase(this._repo); 
  Future<String> execute(String user_id, String project_id) async {
    return await _repo.addMemberIntoProject(user_id, project_id); 
  }
}