import 'package:bloc/bloc.dart';
import 'package:to_do/features/projects/domain/entities/project_member_entity.dart';
import 'package:to_do/features/projects/domain/usecase/fetch_member_by_project_uc.dart';


class MemberProjectCubit extends Cubit<List<ProjectMemberEntity>> {
  final FetchMemberByProjectUc fetchMemberByProjectUc; 
  List<ProjectMemberEntity> members = [];

  MemberProjectCubit(this.fetchMemberByProjectUc) : super([]); // hoặc super(members)

  Future<void> fetchMembers(String projectId) async {
    final members = await fetchMemberByProjectUc.execute(projectId); 
    emit(members); 
  }
}
