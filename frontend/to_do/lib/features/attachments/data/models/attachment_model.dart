import 'package:to_do/features/attachments/domain/entity/attachment_entity.dart';
import 'package:to_do/features/auth/data/models/user_model.dart';

class AttachmentModel extends AttachmentEntity {
  const AttachmentModel({
    required super.id, 
    required super.fileName, 
    required super.fileUrl, 
    required super.uploadAt, 
    required super.uploadedBy, 
    required super.uploader,
    super.is_main 
  }); 

  factory AttachmentModel.fromJson(Map<String,dynamic>json) {
    return AttachmentModel(
      is_main: json['is_main'] ?? false,
      id: json['id'] as String,
      fileName: json['name'] as String,
      fileUrl: json['url'] as String,
      uploadedBy: json['uploadedBy'] as String,
      uploadAt: DateTime.parse(json['createdAt'] as String),
      uploader: UserModel.fromJson(json['uploader'] as Map<String, dynamic>, 
      
      
      )
    ); 
  }
}