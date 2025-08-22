import 'package:to_do/features/comments/domain/entity/comment_entity.dart';
import 'package:to_do/features/comments/domain/repository/comment_repository.dart';

class FetchCommentByTaskUsecase { 
  final CommentRepository repo; 
  const FetchCommentByTaskUsecase(this.repo); 
  Future<List<CommentEntity>> fetchCommnents(String taskId) async {
    return await repo.fetchComments(taskId); 
  }
}