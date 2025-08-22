import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/domain/repository/task_repository.dart';

class FetchTaskForProjectUsecase {
  final TaskRepository _repo; 
  const FetchTaskForProjectUsecase(this._repo); 
  Future<List<TaskEntity>> execute([String? projectId]) async {
    print('Fetch Task ở USECASE'); 
    print(_repo.fetchTasksByProject(projectId)); 
    return await _repo.fetchTasksByProject(projectId); 
  }
}