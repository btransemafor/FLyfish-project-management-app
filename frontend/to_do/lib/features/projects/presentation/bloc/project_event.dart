import 'package:equatable/equatable.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProject extends ProjectEvent {}

class FetchMemberByProject extends ProjectEvent {
  final String projectId;
  FetchMemberByProject(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class CreateProject extends ProjectEvent {
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final String leader_id;

  CreateProject({this.description = '', this.endDate, this.leader_id = '', this.name='',
      this.startDate, this.status});

  @override
  List<Object?> get props =>
      [name, description, leader_id, startDate, endDate, status, status];
}


class AddMemberIntoProject extends ProjectEvent {
  final String user_id; 
  final String project_id; 
  AddMemberIntoProject(this.project_id, this.user_id); 

  @override     
  List<Object?> get props => [user_id, project_id];
}

class FetchProjectById extends ProjectEvent {
 final String project_id; 
 FetchProjectById(this.project_id); 

 @override    
 List<Object> get props => [project_id];

}