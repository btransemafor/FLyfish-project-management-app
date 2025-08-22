import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/domain/repository/task_repository.dart';

class FetchTasktodayUsecase {
 final TaskRepository _repo; 
 const FetchTasktodayUsecase(this._repo); 

 Future<List<TaskEntity>> execute() async {
  final tasks = await _repo.fetchTaskToday();
//  print('Test Task 0:  ${tasks[0].title}');
  return tasks; 
 } 
}