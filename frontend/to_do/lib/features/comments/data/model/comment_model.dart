import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/comments/domain/entity/comment_entity.dart';

class CommentModel extends CommentEntity {
  CommentModel({
    required super.id,
    required super.content,
    required super.user,
    required super.taskId,
    required super.createdAt,
    required super.replies
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
     replies: (json['replies'] is List)
    ? (json['replies'] as List)
        .where((item) => item is Map<String, dynamic>)
        .map((item) => CommentEntity.fromJson(item))
        .toList()
    : [],

      id: json['id'],
      taskId: json['taskId'],
      content: json['content'],
      user: UserEntity.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(), // hoặc để null nếu field này nullable,
    );
  }
}

extension CommentModelMapper on CommentModel {
  CommentEntity toEntity() {
    return CommentEntity(
      id: this.id,
      content: this.content,
      user: this.user,
      taskId: this.taskId,
      createdAt: this.createdAt,
    );
  }
}
