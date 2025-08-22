
import 'package:to_do/features/task/domain/repository/task_repository.dart';

class RemoveUserFromTaskUsecase {
  final TaskRepository _repo; 
  const RemoveUserFromTaskUsecase(this._repo); 

  Future<bool> execute(String user_id, String task_id) async {
    return await _repo.removeUserFromTask(user_id, task_id); 
  }
}