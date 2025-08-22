import 'package:file_picker/file_picker.dart';
import 'package:to_do/features/attachments/data/resource/attachment_data_remote.dart';
import 'package:to_do/features/attachments/domain/entity/attachment_entity.dart';
import 'package:to_do/features/attachments/domain/repository/attachment_repository.dart';

class AttachmentRepositoryImpl extends AttachmentRepository {
  final AttachmentDataRemote _dataRemote; 
  AttachmentRepositoryImpl(this._dataRemote); 

  @override   
  Future<List<AttachmentEntity>> getFilesByTask(String taskId) async {
      final data = await _dataRemote.getFilesByTask(taskId); 
      return data.map((item) => AttachmentEntity.fromModel(item)).toList(); 
  }

  Future<List<AttachmentEntity>> uploadFile(String taskId, FilePickerResult result, [bool? is_main]) async {
    return await _dataRemote.uploadFile(taskId, result, is_main); 
  }
}