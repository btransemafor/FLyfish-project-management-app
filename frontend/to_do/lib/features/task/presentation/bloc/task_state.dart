import 'package:equatable/equatable.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

// ----- Trạng thái khởi tạo -----
class TaskInitial extends TaskState {}

// ----- Trạng thái loading chung -----
class TaskLoading extends TaskState {}

// ----- Load list thành công -----
class TaskLoadSuccess extends TaskState {
  final List<TaskEntity> tasks;
  final String? message;

  const TaskLoadSuccess({this.tasks = const [], this.message});

  @override
  List<Object?> get props => [tasks];
}

// ----- Lỗi -----
class TaskError extends TaskState {
  final String error;

  const TaskError(this.error);

  @override
  List<Object?> get props => [error];
}

// ----- Tạo task thành công -----
class TaskCreatedSuccess extends TaskState {
  final TaskEntity task;
  final List<TaskEntity> tasks; // giữ nguyên danh sách hiện tại

  const TaskCreatedSuccess(this.task, {this.tasks = const []});

  @override
  List<Object?> get props => [task, tasks];
}

// ----- Cập nhật task thành công -----
class TaskUpdatedSuccess extends TaskState {
  final TaskEntity task;
  final List<TaskEntity> tasks; // giữ nguyên danh sách hiện tại

  const TaskUpdatedSuccess(this.task, {this.tasks = const []});

  @override
  List<Object?> get props => [task, tasks];
}

// ----- Xóa task thành công -----
class TaskDeleteSuccess extends TaskState {
  final String deletedTaskId;
  final List<TaskEntity> tasks; // giữ nguyên danh sách hiện tại

  const TaskDeleteSuccess(this.deletedTaskId, {this.tasks = const []});

  @override
  List<Object?> get props => [deletedTaskId, tasks];
}

// ----- Lấy chi tiết task thành công -----
class TaskDetailFetchedSuccess extends TaskState {
  final TaskEntity? task;
  final List<TaskEntity> tasks; // giữ nguyên danh sách hiện tại

  const TaskDetailFetchedSuccess(this.task, {this.tasks = const []});

  @override
  List<Object?> get props => [task, tasks];
}

class TaskTodayFetchSuccess extends TaskState {
  final List<TaskEntity> todayTasks;
  //final List<TaskEntity> tasks; // giữ nguyên danh sách hiện tại

  const TaskTodayFetchSuccess({this.todayTasks = const []});

  @override
  List<Object?> get props => [todayTasks];
}


// Thêm vào task_state.dart
class UserOfTaskRemovedSuccess extends TaskState {
  final TaskEntity updatedTask;
  
  const UserOfTaskRemovedSuccess({required this.updatedTask});
  
  @override
  List<Object?> get props => [updatedTask];
  @override
  String toString() => 'UserOfTaskRemovedSuccess(updatedTask: $updatedTask)';
}