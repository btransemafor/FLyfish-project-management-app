import 'package:equatable/equatable.dart';
enum TaskActionStatus {
  none,
  created,
  updated,
  deleted,
  error,
}

abstract class TaskEvent extends Equatable {
  @override 
  List<Object?> get props => []; 
}

class LoadTask extends TaskEvent {
  final String? status;

  LoadTask([this.status]);

  @override
  List<Object?> get props => [status];
}

class LoadTaskForAProject extends TaskEvent {
  final String? projectId; 
  LoadTaskForAProject([this.projectId]);

  @override
  List<Object?> get props => [projectId];
}

class UpdateTask extends TaskEvent {
  final String taskId;
  final String? projectId; // Thêm projectId
  final Map<String, dynamic> updateField;

  UpdateTask({
    required this.taskId,
    this.projectId,
    required this.updateField,
  });

  @override   
  List<Object?> get props => [taskId, updateField, projectId]; 
}

class CreateTask extends TaskEvent {
  final Map<String,dynamic> fieldTask; 
  CreateTask(this.fieldTask); 
  @override   
  List<Object?> get props => [fieldTask]; 
}

class GetCacheTasks extends TaskEvent {
  @override    
  List<Object> get props => []; 
}


class FetchTaskDetail extends TaskEvent {
  final String id; 
  FetchTaskDetail(this.id); 
  @override    
  List<Object> get props => [id]; 
}

// DELETE TASK 
class DeleteTaskById extends TaskEvent {
  final String id; 
  final TaskActionStatus actionStatus;
  DeleteTaskById(this.id, this.actionStatus); 
  @override    
  List<Object> get props => [id]; 
}

class FetchTaskToday extends TaskEvent {
  @override    
  List<Object> get props => []; 
}


class TaskReset extends TaskEvent {
  @override    
  List<Object> get props => []; 
}

class RemoveUserFromTaskEvent extends TaskEvent {
  final String user_id; 
  final String task_id; 
  RemoveUserFromTaskEvent(this.task_id, this.user_id); 

  @override    
  List<Object> get props => [user_id, task_id]; 
}