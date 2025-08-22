import 'package:equatable/equatable.dart';
import 'package:to_do/features/attachments/domain/entity/attachment_entity.dart';

class AttachmentState extends Equatable {
  @override
  List<Object> get props => [];
}

class AttachmentInitial extends AttachmentState {}

class AttachmentLoading extends AttachmentState {}

class AttachmentFetchSuccess extends AttachmentState {
  final List<AttachmentEntity> files;
  AttachmentFetchSuccess({required this.files});
  @override
  List<Object> get props => [files];
}

class AttachmentError extends AttachmentState {
  final String error;
  AttachmentError(this.error);

  @override
  List<Object> get props => [error];
}


class FileUploadedSuccess extends AttachmentState {
  final AttachmentEntity attach; 
  FileUploadedSuccess(this.attach); 
  @override   
  List<Object> get props => [attach]; 
}


class AttachmentUploading extends AttachmentState {
  
}