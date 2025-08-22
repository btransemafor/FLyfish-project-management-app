import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

class AttachmentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchTaskFiles extends AttachmentEvent {
  final String taskId;

  FetchTaskFiles({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

class UploadFile extends AttachmentEvent {
  final String taskId;
  final FilePickerResult result; 
  final bool is_main ; 
  UploadFile({required this.taskId, required this.result, this.is_main = true });
  @override
  List<Object> get props => [taskId, result];
}
