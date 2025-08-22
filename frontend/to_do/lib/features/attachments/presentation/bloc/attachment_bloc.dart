import 'package:bloc/bloc.dart';
import 'package:to_do/features/attachments/domain/entity/attachment_entity.dart';
import 'package:to_do/features/attachments/domain/usecase/fetch_files_by_task_usecase.dart';
import 'package:to_do/features/attachments/domain/usecase/upload_file_usecase.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_event.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttachmentBloc extends Bloc<AttachmentEvent, AttachmentState> {
  final FetchFilesByTaskUsecase _fetchFilesByTaskUsecase;
  final UploadFileUsecase _uploadFileUsecase;

  AttachmentBloc(this._fetchFilesByTaskUsecase, this._uploadFileUsecase)
      : super(AttachmentInitial()) {
    on<FetchTaskFiles>(_onFetchTaskFiles);
    on<UploadFile>(_onUploadFile);
  }

  Future<void> _onUploadFile(
      UploadFile event, Emitter<AttachmentState> emit) async {
    emit(AttachmentUploading());
    try {
      final newFile =
          await _uploadFileUsecase.uploadFile(event.taskId, event.result, event.is_main);
      final currentState = state;
       final updateFiles = List<AttachmentEntity>.from(files);

        for (var i in newFile) {
          updateFiles.add(i);
        }
        emit(AttachmentFetchSuccess(files: updateFiles));
      
    } catch (error) {
      emit(AttachmentError(error.toString()));
    }
  }

  Future<void> _onFetchTaskFiles(
      FetchTaskFiles event, Emitter<AttachmentState> emitter) async {
    emit(AttachmentLoading());
    try {
      final fetchFiles = await _fetchFilesByTaskUsecase.execute(event.taskId);
      files = fetchFiles;
      emit(AttachmentFetchSuccess(files: files));
    } catch (error) {
      emit(AttachmentError(error.toString()));
    }
  }

  List<AttachmentEntity> files = [];
}
