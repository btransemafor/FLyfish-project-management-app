import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/home/presentation/bloc/home_event.dart';
import 'package:to_do/features/home/presentation/bloc/home_state.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/projects/domain/usecase/fetch_list_project_usecase.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/domain/usecase/fetch_task_usecase.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchListProjectUsecase _fetchProjectUS;
  final FetchTaskUsecase _fetchTaskUsecase;

  List<ProjectEntity> projects = []; 
  List<TaskEntity> tasks = []; 

  HomeBloc(
    this._fetchProjectUS,
    this._fetchTaskUsecase,
  ) : super(HomeInitial()) {
    on<LoadHomeData>(_loadContentHome);
    on<UpdateProjects>(_updateProjects); 
    on<UpdateListHomeTask>(_onUpdateHomeTask);

  }

  Future<void> _loadContentHome(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
     final fetchedProjects = await _fetchProjectUS.execute();
    final fetchedTasks = await _fetchTaskUsecase.execute(countNearestCurrent: event.countNearestCurrent);

    // Gán lại giá trị cho biến instance
    projects = fetchedProjects;
    tasks = fetchedTasks;
      emit(HomeLoadSuccess(projects: projects, tasks: tasks));
    } catch (e) {
      emit(HomeFailure("Failed to load data $e"));
    }
  }

  void _updateProjects(UpdateProjects event, Emitter<HomeState> emit) {
    projects = event.projects; // Cập nhật lại biến instance
    emit(HomeLoadSuccess(projects: projects, tasks: tasks));
  }

void _onUpdateHomeTask(UpdateListHomeTask event, Emitter<HomeState> emit) {
  final updateListTask = List<TaskEntity>.from(tasks);
  
  // Kiểm tra nếu task là today hoặc trong tương lai gần
  final now = DateTime.now();
  final taskDate = event.newTask.dueDate;
  final isToday = taskDate!.year == now.year && 
                  taskDate!.month == now.month && 
                  taskDate!.day == now.day;
  
  if (isToday || taskDate.isAfter(now)) {
    updateListTask.add(event.newTask);
    tasks = updateListTask; // Cập nhật biến instance
    emit(HomeLoadSuccess(projects: projects, tasks: updateListTask));
  } else {
    // Nếu không phải today, vẫn emit state hiện tại
    emit(HomeLoadSuccess(projects: projects, tasks: tasks));
  }
}


}
