import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:to_do/features/attachments/data/models/attachment_model.dart';

import '../../../auth/domain/entities/user_entity.dart';

part 'attachment_entity.g.dart';

@JsonSerializable()
class AttachmentEntity extends Equatable {
  final String id;
  final String fileName;
  final String fileUrl;
  final String uploadedBy;
  final DateTime uploadAt;
  final UserEntity uploader;
  final bool is_main; 

  const AttachmentEntity({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedBy,
    required this.uploadAt,
    required this.uploader,
    this.is_main = false
  });

  factory AttachmentEntity.fromJson(Map<String, dynamic> json) =>
      _$AttachmentEntityFromJson(json);
  


  Map<String, dynamic> toJson() => _$AttachmentEntityToJson(this);

  factory AttachmentEntity.fromModel(AttachmentModel model) {
    return AttachmentEntity(id: model.id, 
              fileName: model.fileName, 
    fileUrl: model.fileUrl, 
    uploadedBy: model.uploadedBy, uploadAt: model.uploadAt, uploader: model.uploader, is_main: model.is_main ?? false); 
  }
 
  @override
  List<Object> get props => [id, fileName, fileUrl, uploadAt, uploadedBy, uploader, is_main];
}