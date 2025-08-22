import 'package:equatable/equatable.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';

abstract class HomeState extends Equatable {
  @override    
  List<Object?> get props => []; 
}

class HomeInitial extends HomeState{}
class HomeLoading extends HomeState{}

class HomeLoadSuccess extends HomeState {
  final List<ProjectEntity>? projects;
  final List<TaskEntity>? tasks;

  HomeLoadSuccess({
    this.projects,
    this.tasks,
  });

  @override
  List<Object?> get props => [projects, tasks];
}

class HomeFailure extends HomeState {
  final String message;

  HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}

