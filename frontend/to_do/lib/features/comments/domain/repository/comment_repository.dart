
import 'package:to_do/features/comments/domain/entity/comment_entity.dart';

abstract class CommentRepository {
  Future<List<CommentEntity>> fetchComments(String taskId);
  Stream<CommentEntity> listenToNewComments(String taskId);
  Future<CommentEntity> sendComment(String taskId, String content, String userId);
  Future<void> leaveCommentRoom(String taskId);
  Future<void> sendCommentViaSocket({
  required String taskId,
  required String content,
  required String userId,
  String? parentId
}); 
}