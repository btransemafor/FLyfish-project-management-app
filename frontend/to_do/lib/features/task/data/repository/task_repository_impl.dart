import 'package:to_do/features/task/data/models/task_model.dart';
import 'package:to_do/features/task/data/resource/task_remote_data.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/domain/repository/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteData _remoteData;
  const TaskRepositoryImpl(this._remoteData);

  @override
  Future<List<TaskEntity>> fetchTasks(
      [String? status, int? countNearestCurrent]) async {
    final data = await _remoteData.fetchTask(status, countNearestCurrent)
        as List<dynamic>;
    print(data);
    return data
        .map((i) => TaskEntity(
          projectId: i.projectId,
            id: i.id,
            description: i.description,
            title: i.title,
            status: i.status,
            priority: i.priority,
            dueDate: i.dueDate,
            creator: i.creator,
            assignees: i.assignees))
        .toList();
  }

  @override
  Future<List<TaskEntity>> fetchTasksByProject([String? projectId]) async {
    final data = await _remoteData.fetchTasksByProject(projectId);
    print(data);
    return data
        .map((i) => TaskEntity(
          projectId: i.projectId,
            id: i.id,
            description: i.description,
            title: i.title,
            status: i.status,
            priority: i.priority,
            dueDate: i.dueDate,
            creator: i.creator,
            assignees: i.assignees))
        .toList();
  }

  @override
  Future<TaskEntity> updateTask(
      String taskId, Map<String, dynamic> updateFields) async {
    final data = await _remoteData.updateTask(taskId, updateFields);
    print(data.description);
    return TaskEntity(
      projectId: data.projectId,
        assignees: data.assignees,
        id: data.id,
        description: data.description,
        title: data.title,
        status: data.status,
        priority: data.priority,
        dueDate: data.dueDate,
        creator: data.creator);
  }

  @override
  Future<TaskEntity> createTask(Map<String, dynamic> fieldTask) async {
    final data = await _remoteData.createTask(fieldTask);
    return TaskEntity(
      projectId: data.projectId,
        assignees: data.assignees,
        id: data.id,
        description: data.description,
        title: data.title,
        status: data.status,
        priority: data.priority,
        dueDate: data.dueDate,
        creator: data.creator);
  }

  @override
  Future<TaskEntity> fetchTaskById(String id) async {
    final data = await _remoteData.fetchTaskById(id);
    return TaskEntity(
         projectId: data.projectId,
        assignees: data.assignees,
        id: data.id,
        description: data.description,
        title: data.title,
        status: data.status,
        priority: data.priority,
        dueDate: data.dueDate,
        creator: data.creator);
  }

  @override    
  Future<bool> deleteTaskById(String id) async {
    return await _remoteData.deteleTaskById(id); 
  }

  @override      
  Future<List<TaskEntity>> fetchTaskToday() async {
    final model  = await _remoteData.fetchTaskToday();
    print('Số lượng Task Hôm nay: ${model.length}');
   
    return model.map((item) => TaskEntity(
      projectId: item.projectId,
      id: item.id, 
      description: item.description, 
      title: item.title, 
      status: item.status, 
      priority: item.priority, 
      dueDate: item.dueDate, 
      creator: item.creator)).toList(); 
  }
  @override   
  Future<bool> removeUserFromTask(String user_id, String task_id) async {
    return await _remoteData.removeUserFromTask(user_id, task_id); 
  }
}
