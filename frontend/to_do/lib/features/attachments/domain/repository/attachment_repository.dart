import 'package:file_picker/file_picker.dart';
import 'package:to_do/features/attachments/domain/entity/attachment_entity.dart';

abstract class AttachmentRepository {
  Future<List<AttachmentEntity>> getFilesByTask(String taskId); 
  Future<List<AttachmentEntity>> uploadFile(String taskId, FilePickerResult result, [bool? is_main]);
}