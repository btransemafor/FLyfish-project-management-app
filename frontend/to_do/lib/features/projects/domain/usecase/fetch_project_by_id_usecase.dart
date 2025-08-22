import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/projects/domain/repository/project_repository.dart';

class FetchProjectByIdUsecase {
  final ProjectRepository _repo; 
  const FetchProjectByIdUsecase(this._repo); 
  Future<ProjectEntity> execute(String project_id) async {
    return await _repo.fetchProjectById(project_id); 
  }
}