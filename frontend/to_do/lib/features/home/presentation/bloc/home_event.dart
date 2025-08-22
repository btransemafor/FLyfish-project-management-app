import 'package:equatable/equatable.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';

abstract class HomeEvent extends Equatable {
  @override   
  List<Object?> get props => []; 
}

class LoadHomeData extends HomeEvent {
  final String? status; 
  final int? countNearestCurrent; 
  LoadHomeData({this.countNearestCurrent, this.status});

  @override   
  List<Object?> get props => [status,countNearestCurrent]; 
}

class RefreshHomeData extends HomeEvent {
  RefreshHomeData();
}

class UpdateProjects extends HomeEvent {
  final List<ProjectEntity> projects; 
  UpdateProjects(this.projects); 
}

class UpdateListHomeTask extends HomeEvent {
  final TaskEntity newTask; 
  UpdateListHomeTask(this.newTask);
  @override   
  List<Object?> get props => [newTask]; 
}
