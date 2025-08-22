import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/projects/domain/repository/project_repository.dart';

class CreateProjectUsecase {
  final ProjectRepository _repo;
  const CreateProjectUsecase(this._repo);

  Future<ProjectEntity> execute(
    String name,
    String description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String leader_id,
  ) async {
    print('Test crate project usecase'); 
    
    return await _repo.createProject(
        name, description, startDate, endDate, status, leader_id);
  }
  
}
