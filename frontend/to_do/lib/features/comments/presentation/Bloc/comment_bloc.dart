// 2. Sử dụng trong Bloc
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:to_do/features/comments/domain/entity/comment_entity.dart';
import 'package:to_do/features/comments/domain/usecase/fetch_comment_by_task_usecase.dart';
import 'package:to_do/features/comments/domain/usecase/sendCmt_via_socket_usecase.dart';
import 'package:to_do/features/comments/domain/usecase/stream_comment_usecase.dart';
import 'package:to_do/features/comments/presentation/Bloc/comment_event.dart';
import 'package:to_do/features/comments/presentation/Bloc/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final StreamCommentsUseCase streamCommentsUseCase;
  final FetchCommentByTaskUsecase fetchCommentByTaskUsecase;
  final SendcmtViaSocketUsecase sendcmtViaSocketUsecase;

  StreamSubscription<CommentEntity>? _commentStreamSubscription;

  CommentBloc(
      {required this.streamCommentsUseCase,
      required this.fetchCommentByTaskUsecase,
      required this.sendcmtViaSocketUsecase})
      : super(CommentInitial()) {
    on<StartListeningToComments>(_onStartListening);
    on<StopListeningToComments>(_onStopListening);
    on<AddNewComment>(_onAddNewComment);
    on<FetchCommentsEvent>(_onFetchComments);
    on<CreateComment>(_onCreateComment);
  }

  void _onStartListening(
      StartListeningToComments event, Emitter<CommentState> emit) {
    try {
      // Hủy subscription cũ nếu có
      _commentStreamSubscription?.cancel();

      // Lắng nghe comment mới
      _commentStreamSubscription =
          streamCommentsUseCase.call(event.taskId).listen(
        (newComment) {
          // Thêm comment mới vào state
          add(AddNewComment(newComment));
        },
        onError: (error) {
          print('Comment stream error: $error');
          emit(CommentError('Failed to listen to new comments: $error'));
        },
      );
    } catch (e) {
      emit(CommentError('Failed to start listening: $e'));
    }
  }

  void _onStopListening(
      StopListeningToComments event, Emitter<CommentState> emit) {
    _commentStreamSubscription?.cancel();
    _commentStreamSubscription = null;
  }

  void _onAddNewComment(AddNewComment event, Emitter<CommentState> emit) {
    final currentState = state;
    if (currentState is CommentLoaded) {
      // Thêm comment mới vào danh sách hiện tại
      final updatedComments = List<CommentEntity>.from(currentState.comments);

      final parentId = event.comment.parentId?.trim();

      if (parentId != null && parentId.isNotEmpty) {
        print('Comment này là comment con');
        final parentComment = updatedComments.firstWhere(
          (item) => item.id == parentId,
          orElse: () => throw Exception('Parent comment not found'),
        );
        parentComment.replies.add(event.comment);
      } else {
         print('Comment này không phải là comment con');
        updatedComments.add(event.comment);
      }

      emit(CommentLoaded(updatedComments));
      // Kiểm tra xem comment đã tồn tại chưa (tránh trùng lặp)
      // final existingIndex = updatedComments.indexWhere((c) => c.id == event.comment.id);
/*       if (existingIndex == -1) {

        updatedComments.add(event.comment);
        emit(CommentLoaded(updatedComments));
      } */
    }
  }

  void _onFetchComments(
      FetchCommentsEvent event, Emitter<CommentState> emit) async {
    emit(CommentLoading());
    try {
      final comments =
          await fetchCommentByTaskUsecase.fetchCommnents(event.taskId);
      emit(CommentLoaded(comments));

      // Bắt đầu lắng nghe comment mới sau khi load xong
      add(StartListeningToComments(event.taskId));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _commentStreamSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCreateComment(
      CreateComment event, Emitter<CommentState> emit) async {
    await sendcmtViaSocketUsecase.call(
        taskId: event.taskId,
        content: event.content,
        userId: event.userId,
        parentId: event.parentId);
  }
}
