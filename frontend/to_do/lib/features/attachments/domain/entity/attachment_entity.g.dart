// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttachmentEntity _$AttachmentEntityFromJson(Map<String, dynamic> json) =>
    AttachmentEntity(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      uploadedBy: json['uploadedBy'] as String,
      uploadAt: DateTime.parse(json['uploadAt'] as String),
      uploader: UserEntity.fromJson(json['uploader'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AttachmentEntityToJson(AttachmentEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'fileUrl': instance.fileUrl,
      'uploadedBy': instance.uploadedBy,
      'uploadAt': instance.uploadAt.toIso8601String(),
      'uploader': instance.uploader,
    };
