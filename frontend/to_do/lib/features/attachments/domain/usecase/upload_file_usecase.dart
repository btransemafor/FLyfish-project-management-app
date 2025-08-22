import 'package:file_picker/file_picker.dart';
import 'package:to_do/features/attachments/domain/entity/attachment_entity.dart';
import 'package:to_do/features/attachments/domain/repository/attachment_repository.dart';

class UploadFileUsecase {
  final AttachmentRepository _repo; 
  const UploadFileUsecase(this._repo); 

  Future<List<AttachmentEntity>> uploadFile(String taskId, FilePickerResult result, [bool? is_main]) async {
    return await _repo.uploadFile(taskId, result, is_main); 
  }
}