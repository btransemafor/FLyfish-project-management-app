// lib/features/projects/presentation/bloc/project_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/projects/domain/entities/project_member_entity.dart';
import 'package:to_do/features/projects/domain/usecase/add_member_project_usecase.dart';
import 'package:to_do/features/projects/domain/usecase/create_project_usecase.dart';
import 'package:to_do/features/projects/domain/usecase/fetch_list_project_usecase.dart';
import 'package:to_do/features/projects/domain/usecase/fetch_member_by_project_uc.dart';
import 'package:to_do/features/projects/domain/usecase/fetch_project_by_id_usecase.dart';
import 'package:to_do/features/projects/presentation/bloc/project_event.dart';
import 'package:to_do/features/projects/presentation/bloc/project_state.dart';
import 'package:to_do/features/users/presentation/bloc/user_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final FetchListProjectUsecase fetchListProjectUsecase;
  final FetchMemberByProjectUc  _fetchMemberByProjectUc;  
  final CreateProjectUsecase _createProjectUsecase; 
  final FetchProjectByIdUsecase _fetchProjectByIdUsecase; 
  final AddMemberProjectUsecase _addMemberProjectUsecase; 
  List<ProjectEntity> projects = []; // Lưu trữ danh sách dự án

  List<ProjectMemberEntity> members = []; 

  ProjectBloc(this.fetchListProjectUsecase, this._fetchMemberByProjectUc, this._createProjectUsecase, 
  this._addMemberProjectUsecase, 
  
  this._fetchProjectByIdUsecase) : super(ProjectInitial()) {
    on<FetchProject>(_onFetchListProject);
    on<FetchMemberByProject>(_onFetchMember); 
    on<CreateProject>(_onCreateProject); 
    on<FetchProjectById>(_onFetchProjectById); 
    on<AddMemberIntoProject> (_onAddMemberIntoProject); 

  }

  Future<void> _onFetchListProject(FetchProject event, Emitter<ProjectState> emit) async {

    emit(ProjectLoading());
    try {
      final projects = await fetchListProjectUsecase.execute();
      emit(ProjectSuccess(projects)); // Emit success even if empty; handle empty state in UI
    } catch (error) {
      emit(ProjectError(error.toString()));
    }
  }



  Future<void>_onFetchMember(FetchMemberByProject event , Emitter<ProjectState> emit) async {
    emit(ProjectLoading()); 
    try {
      final fetchedmembers = await _fetchMemberByProjectUc.execute(event.projectId); 
      members = fetchedmembers; 
      
      emit(MembersOfProjectSuccess(members)); 
    }
    catch(error) {
      emit(ProjectError(error.toString()));
    }
  }

 Future<void> _onCreateProject(CreateProject event, Emitter<ProjectState> emit) async {
  emit(ProjectLoading());
  try {
    final project = await _createProjectUsecase.execute(event.name, event.description, event.startDate, event.endDate, event.status, event.leader_id);

    print(project.description); 
    //await platform.invokeMethod('showNotification', {'message': 'Project ${event.name} created!'});
    final projects = await fetchListProjectUsecase.execute();
    print('OMGNICE'+ projects[1].name); 
    print(projects.length);
    emit(ProjectSuccess(projects));
  } catch (error) {
    print(error.toString()); 
    emit(ProjectError(error.toString()));
  }
}

Future<void> _onFetchProjectById(FetchProjectById event, Emitter<ProjectState> emit) async {
  emit(ProjectLoading()); 
  try {
        final project = await _fetchProjectByIdUsecase.execute(event.project_id);
        if (project == null) {
          emit(ProjectError('Project not found'));
        } else {
          emit(ProjectFetchSuccess(project));
        }
      } catch (e) {
        emit(ProjectError(e.toString()));
      }
    }
  

// Add member 
Future<void> _onAddMemberIntoProject(AddMemberIntoProject event, Emitter<ProjectState> emit) async {
  emit(ProjectLoading()); 
  try {

    final user_id  = await _addMemberProjectUsecase.execute(event.user_id, event.project_id); 
    if (user_id.isEmpty ||  user_id == '')  {
      emit(AddMemberFailure('user đã được thêm rồi')); 
    }
    emit(ProjectMemberAddedSuccess(user_id)); 
  }

  catch(error) {
    emit(ProjectError('User Này đã là thành viên hoặc Hệ thống bị lỗi')); 
  }
}

}