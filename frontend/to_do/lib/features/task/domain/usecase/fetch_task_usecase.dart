import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/domain/repository/task_repository.dart';

class FetchTaskUsecase {
  final TaskRepository _repo; 
  const FetchTaskUsecase(this._repo); 

  Future<List<TaskEntity>> execute({String? status, int? countNearestCurrent}) async {
    return await _repo.fetchTasks(status, countNearestCurrent); 
  }
}