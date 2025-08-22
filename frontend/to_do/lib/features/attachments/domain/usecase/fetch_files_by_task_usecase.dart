import 'package:to_do/features/attachments/domain/entity/attachment_entity.dart';
import 'package:to_do/features/attachments/domain/repository/attachment_repository.dart';

class FetchFilesByTaskUsecase {
  final AttachmentRepository _repo; 
  FetchFilesByTaskUsecase(this._repo); 

  Future<List<AttachmentEntity>> execute(String taskId) async {
    return _repo.getFilesByTask(taskId); 
  }
}