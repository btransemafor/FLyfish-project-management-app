import 'package:to_do/features/task/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> fetchTasks([String? status, int? countNearestCurrent]); 
  Future<List<TaskEntity>> fetchTasksByProject([String? projectId]); 
  Future<TaskEntity> updateTask(String taskId, Map<String,dynamic> updateFields); 
  Future<TaskEntity> createTask(Map<String, dynamic> fieldTask);
  Future<TaskEntity> fetchTaskById(String id);
  Future<bool> deleteTaskById(String id); 
  Future<List<TaskEntity>> fetchTaskToday(); 
  Future<bool> removeUserFromTask(String user_id, String task_id); 
}