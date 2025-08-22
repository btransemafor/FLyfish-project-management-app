import 'package:to_do/features/projects/domain/entities/project_entity.dart';
import 'package:to_do/features/projects/domain/repository/project_repository.dart';

class FetchListProjectUsecase {
  final ProjectRepository _repository; 
  const FetchListProjectUsecase(this._repository); 

  Future<List<ProjectEntity>> execute([bool? isLeader]) async {
    final data = await _repository.fetchListProject(); 
    print('Xin Chao'+ data[0].name); 
    return await _repository.fetchListProject(); 
  }
}