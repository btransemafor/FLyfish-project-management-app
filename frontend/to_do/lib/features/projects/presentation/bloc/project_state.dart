import 'package:equatable/equatable.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/projects/domain/entities/project_member_entity.dart';

abstract class ProjectState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectError extends ProjectState {
  final String error;
  ProjectError(this.error);
}

class ProjectSuccess extends ProjectState {
  final List<ProjectEntity> projects;
  ProjectSuccess(this.projects);
}

class MembersOfProjectSuccess extends ProjectState {
  final List<ProjectMemberEntity> members;
  MembersOfProjectSuccess(this.members);

  @override
  List<Object> get props => [members];
}

class ProjectCreatedSuccess extends ProjectState {
  final ProjectEntity project;
  ProjectCreatedSuccess(this.project);

  @override
  List<Object> get props => [project];
}

class ProjectMemberAddedSuccess extends ProjectState {
  final String user_id; 
  ProjectMemberAddedSuccess(this.user_id);

  @override
  List<Object> get props => [user_id];
}

class AddMemberFailure extends ProjectState {
  final String mess; 
  AddMemberFailure(this.mess); 
  @override   
  List<Object> get props => [mess];
}

class ProjectFetchSuccess extends ProjectState {
  final ProjectEntity project;
  ProjectFetchSuccess(this.project);
  @override
  List<Object> get props => [project];
}
