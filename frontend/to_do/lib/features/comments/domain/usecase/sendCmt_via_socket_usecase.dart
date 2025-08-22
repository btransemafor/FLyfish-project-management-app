import 'package:to_do/features/comments/domain/repository/comment_repository.dart';
import 'package:to_do/features/comments/domain/usecase/fetch_comment_by_task_usecase.dart';

class SendcmtViaSocketUsecase {
  final CommentRepository _repo; 
  const SendcmtViaSocketUsecase(this._repo); 


  Future<void> call({required String taskId,
  required String content,
  required String userId,
  String? parentId
  }) async {
    await _repo.sendCommentViaSocket(taskId: taskId, content: content, userId: userId, parentId: parentId);
  }

}
