import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/domain/repository/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository _repo; 
  const CreateTaskUseCase(this._repo); 
  Future<TaskEntity> createTask(Map<String, dynamic> fieldTask) async {
    return await _repo.createTask(fieldTask); 
  }
  
}