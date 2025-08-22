import 'package:bloc/bloc.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/domain/usecase/create_task_use_case.dart';
import 'package:to_do/features/task/domain/usecase/delete_task_by_id_usecase.dart';
import 'package:to_do/features/task/domain/usecase/fetch_taskToday_usecase.dart';
import 'package:to_do/features/task/domain/usecase/fetch_task_by_id_usecase.dart';
import 'package:to_do/features/task/domain/usecase/fetch_task_for_project_usecase.dart';
import 'package:to_do/features/task/domain/usecase/fetch_task_usecase.dart';
import 'package:to_do/features/task/domain/usecase/remove_user_from_task_usecase.dart';
import 'package:to_do/features/task/domain/usecase/updateTask_usecase.dart';
import 'package:to_do/features/task/presentation/bloc/task_event.dart';
import 'package:to_do/features/task/presentation/bloc/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FetchTaskUsecase _fetchTaskUsecase;
  final FetchTaskForProjectUsecase _fetchTaskForProjectUsecase;
  final UpdateTaskUsecase _updateTaskUsecase;
  final CreateTaskUseCase _taskUseCase;
  final FetchTaskByIdUsecase _fetchTaskByIdUsecase;
  final DeleteTaskByIdUsecase _deleteTaskUsecase;
  final FetchTasktodayUsecase _fetchTasktodayUsecase;
  final RemoveUserFromTaskUsecase _removeUserFromTaskUsecase;

  List<TaskEntity> tasks = [];
  TaskEntity? task;
  List<TaskEntity> todayTasks = [];
  String? currentProjectId; // Track current project

  TaskBloc(
      this._fetchTaskUsecase,
      this._fetchTaskForProjectUsecase,
      this._updateTaskUsecase,
      this._taskUseCase,
      this._fetchTaskByIdUsecase,
      this._deleteTaskUsecase,
      this._fetchTasktodayUsecase,
      this._removeUserFromTaskUsecase)
      : super(TaskInitial()) {
    on<LoadTask>(_onFetchTask);
    on<LoadTaskForAProject>(_onLoadTaskForAProject);
    on<UpdateTask>(_onUpdateTask);
    on<CreateTask>(_onCreateTask);
    on<GetCacheTasks>(_onGetCacheTasks);
    on<FetchTaskDetail>(_onFetchTaskDetail);
    on<DeleteTaskById>(_onDeleteTaskById);
    on<FetchTaskToday>(_onFetchTaskToday);
    on<TaskReset>(_onResetTask);
    on<RemoveUserFromTaskEvent>(_onRemoveUserFromTask);
  }

  Future<void> _onFetchTask(LoadTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final result = await _fetchTaskUsecase.execute(status: event.status);
      tasks = result;
      currentProjectId = null; // Reset project ID
      emit(TaskLoadSuccess(tasks: tasks));
    } catch (error) {
      emit(TaskError('Error loading tasks: $error'));
    }
  }

  Future<void> _onLoadTaskForAProject(
      LoadTaskForAProject event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final fetchedTasks =
          await _fetchTaskForProjectUsecase.execute(event.projectId);
      print('[SỐ lượng task] ${fetchedTasks.length}');
      tasks = fetchedTasks;
      currentProjectId = event.projectId; // Store current project ID
      emit(TaskLoadSuccess(tasks: tasks));
    } catch (error) {
      emit(TaskError('Error loading tasks: $error'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final updatedTask =
          await _updateTaskUsecase.updateTask(event.taskId, event.updateField);

      if (updatedTask != null) {
        // Cập nhật task trong danh sách local
        tasks =
            tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();

        String message = '';
        if (event.updateField.containsKey('status')) {
          message = 'Cập Nhật Trạng Thái Task Thành Công';
        }

        // Emit TaskUpdatedSuccess để UI có thể xử lý specific logic
        emit(TaskUpdatedSuccess(updatedTask));

        // Sau đó emit lại danh sách đã cập nhật
        emit(TaskLoadSuccess(tasks: tasks));
      } else {
        emit(TaskError('Cập nhật không thành công'));
      }
    } catch (e) {
      emit(TaskError('Lỗi khi cập nhật task: ${e.toString()}'));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      final newTask = await _taskUseCase.createTask(event.fieldTask);

      // Thêm task mới vào đầu danh sách để dễ nhận thấy
      tasks = [newTask, ...tasks];

      // Emit TaskCreatedSuccess với thông tin task mới
      emit(TaskCreatedSuccess(newTask));

      // Sau đó emit lại danh sách với message thành công
      emit(TaskLoadSuccess(
          tasks: tasks, message: 'Tạo 1 Nhiệm Vụ Mới Thành Công'));
    } catch (error) {
      emit(TaskError('Lỗi khi tạo task: ${error.toString()}'));
    }
  }

  void _onGetCacheTasks(GetCacheTasks event, Emitter<TaskState> emit) {
    if (tasks.isNotEmpty) {
      emit(TaskLoadSuccess(tasks: tasks));
    } else {
      emit(TaskInitial());
    }
  }

  Future<void> _onFetchTaskDetail(
      FetchTaskDetail event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final detail = await _fetchTaskByIdUsecase.execute(event.id);
      task = detail;
      emit(TaskDetailFetchedSuccess(task));
    } catch (error) {
      emit(TaskError('Lỗi khi lấy chi tiết task: ${error.toString()}'));
    }
  }

  Future<void> _onDeleteTaskById(
      DeleteTaskById event, Emitter<TaskState> emit) async {
    try {
      // Thực hiện xóa trên server
      await _deleteTaskUsecase.execute(event.id);

      // Cập nhật danh sách local
      tasks = tasks.where((t) => t.id != event.id).toList();

      // Emit TaskDeletedSuccess để UI có thể hiển thị notification
      emit(TaskDeleteSuccess('Xóa Nhiệm Vụ Thành Công'));

      // Sau đó emit lại danh sách đã cập nhật
      emit(TaskLoadSuccess(tasks: tasks));
    } catch (error) {
      emit(TaskError('Lỗi khi xóa task: ${error.toString()}'));
    }
  }

  Future<void> _onFetchTaskToday(
      FetchTaskToday event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final fetchedTodayTasks = await _fetchTasktodayUsecase.execute();

      todayTasks = fetchedTodayTasks;
      print('[TODAY TASKS] ${todayTasks.length}');

      emit(TaskTodayFetchSuccess(todayTasks: todayTasks));
    } catch (error) {
      emit(TaskError('Lỗi khi lấy task hôm nay: ${error.toString()}'));
    }
  }

  void _onResetTask(TaskReset event, Emitter<TaskState> emit) {
    tasks.clear();
    todayTasks.clear();
    task = null;
    currentProjectId = null;
    emit(TaskInitial());
  }

  // Utility methods
  Future<void> refreshCurrentTasks() async {
    if (currentProjectId != null) {
      // Nếu đang xem tasks của một project cụ thể
      add(LoadTaskForAProject(currentProjectId!));
    } else {
      // Nếu đang xem tất cả tasks
      add(LoadTask());
    }
  }

  Future<void> _onRemoveUserFromTask(
      RemoveUserFromTaskEvent event, Emitter<TaskState> emit) async {
    try {
      print('[START] _onRemoveUserFromTask');

      final result = await _removeUserFromTaskUsecase.execute(
          event.user_id, event.task_id);

      if (result) {
        print('[Xóa user thành công]');

        final newTask = await _fetchTaskByIdUsecase.execute(event.task_id);
        task = newTask;
        print(
            '[Task sau khi xóa user]: Assignees: ${task!.assignees.map((u) => u.name).toList()}');
        print('[EMITTING] UserOfTaskRemovedSuccess');
        emit(UserOfTaskRemovedSuccess(updatedTask: task!));
      } else {
        emit(TaskError('Không thể xóa user khỏi task'));
      }
    } catch (error) {
      print('[Lỗi xóa user]: $error');
      emit(TaskError('Lỗi khi xóa user: $error'));
    }
  }

  bool get hasActiveTasks => tasks.any((task) => task.status != 'Completed');

  int get completedTasksCount =>
      tasks.where((task) => task.status == 'Completed').length;

  double get completionPercentage {
    if (tasks.isEmpty) return 0.0;
    return completedTasksCount / tasks.length;
  }

  List<TaskEntity> getTasksByStatus(String status) {
    return tasks.where((task) => task.status == status).toList();
  }

  TaskEntity? getTaskById(String taskId) {
    try {
      return tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> close() {
    print('TaskBloc disposed at ${DateTime.now()}');
    tasks.clear();
    todayTasks.clear();
    return super.close();
  }
}
