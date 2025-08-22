import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/domain/repository/task_repository.dart';

class UpdateTaskUsecase {
  final TaskRepository _repo; 
  const UpdateTaskUsecase(this._repo); 
  Future<TaskEntity> updateTask(String taskId, Map<String,dynamic> updateFields) async {
    return await _repo.updateTask(taskId, updateFields); 
  }
}