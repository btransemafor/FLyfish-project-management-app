import 'package:to_do/features/task/domain/repository/task_repository.dart';

class DeleteTaskByIdUsecase {
  final TaskRepository repo; 
  DeleteTaskByIdUsecase(this.repo); 

  Future<bool> execute(String id) async {
    return await repo.deleteTaskById(id); 
  }
}