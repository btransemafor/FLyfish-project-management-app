import 'package:to_do/features/auth/data/models/user_model.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/projects/data/data_source/project_data_remote.dart';
import 'package:to_do/features/projects/data/model/project_member_model.dart';
import 'package:to_do/features/projects/data/model/project_model.dart';
import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/projects/domain/entities/project_member_entity.dart';
import 'package:to_do/features/projects/domain/repository/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectDataRemote projectDataRemote;
  const ProjectRepositoryImpl(this.projectDataRemote);
  @override
  Future<List<ProjectEntity>> fetchListProject([bool? isLeader]) async {
    print('Đang fetch data project; ');
    List<ProjectModel> data =
        await projectDataRemote.fetchListProject(isLeader);

    print('End Date: ' + data[0].endDate.toString());

    return data
        .map((item) => ProjectEntity(
            id: item.id,
            name: item.name,
            description: item.description,
            endDate: item.endDate,
            startDate: item.startDate,
            status: item.status,
            numberMember: item.numberMember,
            leader_id: item.leader_id,
            numberCompletedTask: item.numberCompletedTask,
            numberTask: item.numberTask,
            members: item.members
                .map((i) => UserEntity(
                    avatar: i.avatar,
                    birthDay: i.birthDay,
                    userId: i.userId,
                    name: i.name,
                    email: i.email,
                    phone: i.phone,
                    active: i.active))
                .toList()))
        .toList();
  }

  @override
  Future<List<ProjectMemberEntity>> fetchMemberByProject(
      String projectId) async {
    List<ProjectMemberModel> data =
        await projectDataRemote.fetchMemberByProject(projectId);

    return data
        .map((item) => ProjectMemberEntity(
            avatar: item.avatar,
            birthDay: item.birthDay,
            id: item.id,
            name: item.name,
            email: item.email,
            phone: item.phone,
            role: item.role,
            projectId: item.projectId))
        .toList();
  }

  @override
  Future<ProjectEntity> createProject(
    String name,
    String description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String leader_id,
  ) async {
    final project = await projectDataRemote.createProject(
        name, description, startDate, endDate, status, leader_id);

    return ProjectEntity(
        id: project.id,
        name: project.name,
        description: project.description,
        startDate: project.startDate,
        endDate: project.endDate,
        status: project.status,
        numberMember: project.numberMember,
        leader_id: project.leader_id);
  }

  @override
  Future<String> addMemberIntoProject(String user_id, String project_id) async {
    return await projectDataRemote.addMemberIntoProject(user_id, project_id);
  }

  @override
  Future<ProjectEntity> fetchProjectById(String project_id) async {
    final data = await projectDataRemote.fetchProjectById(project_id);
    print(data.members[0].name); 
    return ProjectEntity(
        id: data.id,
        name: data.name,
        description: data.description,
        startDate: data.startDate,
        endDate: data.endDate,
        status: data.status,
        numberMember: data.numberMember,
        leader_id: data.leader_id,
        numberTask: data.numberTask,
        numberCompletedTask: data.numberCompletedTask,
        members: data.members
            .map((i) => UserEntity(
                avatar: i.avatar,
                birthDay: i.birthDay,
                userId: i.userId,
                name: i.name,
                email: i.email,
                phone: i.phone,
                active: i.active))
            .toList());
  }
}
