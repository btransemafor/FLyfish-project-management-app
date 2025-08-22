import 'package:to_do/features/comments/domain/entity/comment_entity.dart';
import 'package:to_do/features/comments/domain/repository/comment_repository.dart';

class StreamCommentsUseCase {
  final CommentRepository repository;

  StreamCommentsUseCase(this.repository);

  Stream<CommentEntity> call(String taskId) {
    return repository.listenToNewComments(taskId);
}
}