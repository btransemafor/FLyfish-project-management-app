import 'package:to_do/features/comments/data/resource/comment_data_remote.dart';
import 'package:to_do/features/comments/data/model/comment_model.dart';
import 'package:to_do/features/comments/domain/entity/comment_entity.dart';
import 'package:to_do/features/comments/domain/repository/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final ICommentRemoteDataSource _remoteDataSource;

  CommentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CommentEntity>> fetchComments(String taskId) async {
    try {
      final models = await _remoteDataSource.fetchComments(taskId);

      print('LIST COMMENT: ${models}');
      return models; 
    } catch (e) {
      print('Repository error fetching comments: $e');
      rethrow;
    }
  }

  @override
  Stream<CommentEntity> listenToNewComments(String taskId) {
    try {
      return _remoteDataSource
          .listenToNewComments(taskId);
          
    } catch (e) {
      print('Repository error listening to comments: $e');
      rethrow;
    }
  }

  @override
  Future<CommentEntity> sendComment(
      String taskId, String content, String user_id) async {
    try {
      if (content.trim().isEmpty) {
        throw Exception('Comment content cannot be empty');
      }
      final model =
          await _remoteDataSource.sendComment(taskId, content, user_id);
      return model.toEntity();
    } catch (e) {
      print('Repository error sending comment: $e');
      rethrow;
    }
  }

  @override
  Future<void> leaveCommentRoom(String taskId) async {
    try {
      await _remoteDataSource.leaveCommentRoom(taskId);
    } catch (e) {
      print('Repository error leaving comment room: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendCommentViaSocket({
    required String taskId,
    required String content,
    required String userId,
    String? parentId
  }) async {
    await _remoteDataSource.sendCommentViaSocket(
        taskId: taskId, content: content, userId: userId, 
        parentId: parentId
        );
  }

  void dispose() {
    _remoteDataSource.dispose();
  }
}
