import 'package:equatable/equatable.dart';
import 'package:to_do/features/comments/domain/entity/comment_entity.dart';

// 3. Events cho Bloc
abstract class CommentEvent {}

class FetchCommentsEvent extends CommentEvent {
  final String taskId;
  FetchCommentsEvent(this.taskId);
}

class StartListeningToComments extends CommentEvent {
  final String taskId;
  StartListeningToComments(this.taskId);
}

class StopListeningToComments extends CommentEvent {}

class AddNewComment extends CommentEvent {
  final CommentEntity comment;  
  AddNewComment(this.comment);
}


class CreateComment extends CommentEvent {
  final String taskId;
  final String content;
  final String userId;
  final String? parentId ;

  CreateComment(this.content, this.taskId, this.userId, this.parentId); 
}