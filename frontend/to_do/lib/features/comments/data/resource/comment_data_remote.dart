import 'dart:async';
import 'package:dio/dio.dart';
import 'package:to_do/core/networks/dio_client.dart';
import 'package:to_do/core/socket/socket_manager.dart';
import 'package:to_do/features/comments/data/model/comment_model.dart';
import 'package:to_do/features/comments/domain/entity/comment_entity.dart';

abstract class ICommentRemoteDataSource {
  Future<List<CommentEntity>> fetchComments(String taskId);
  Stream<CommentEntity> listenToNewComments(String taskId);
  Future<CommentModel> sendComment(
      String taskId, String content, String userId);
  Future<void> sendCommentViaSocket(
      {required String taskId,
      required String content,
      required String userId,
      String? parentId});
  Future<void> leaveCommentRoom(String taskId);
  void dispose();
}
// Fix for the socket handler issue

// WRONG - This will cause the error you're seeing:
// socket.on('connect', () {
//   print('Socket reconnected, rejoining comment room');
//   socket.emit('join_comment', {'taskId': taskId}); // taskId might be null or a function here
// });

// CORRECT - Store the taskId as a class variable and use it properly:

class CommentRemoteDataSource implements ICommentRemoteDataSource {
  final Dio _dioClient;
  final SocketManager _socket;

  StreamController<CommentEntity>? _controller;
  String? _currentTaskId; // Store current task ID
  bool _isListening = false;

  CommentRemoteDataSource(this._dioClient, this._socket);

  @override
  Stream<CommentEntity> listenToNewComments(String taskId) {
    try {
      // Validate taskId parameter
      if (taskId.isEmpty) {
        throw Exception('TaskId cannot be empty');
      }

      // Check if socket is available and connected
      if (!_socket.isInitialized || !_socket.isConnected) {
        throw Exception('Socket not connected. Please check your connection.');
      }

      final socket = _socket.getSocket();
      if (socket == null) {
        throw Exception('Socket instance not available');
      }

      // Store the current taskId
      _currentTaskId = taskId;

      // Clean up previous listeners if switching to different task
      if (_controller != null) {
        _cleanupListener();
      }

      _controller = StreamController<CommentEntity>.broadcast(
        onListen: () => _setupSocketListener(),
        onCancel: () => _cleanupListener(),
      );

      return _controller!.stream;
    } catch (e) {
      print('Error setting up comment listener: $e');
      throw Exception('Failed to listen to comments: $e');
    }
  }

  void _setupSocketListener() {
    if (_isListening || _currentTaskId == null) return;

    try {
      final socket = _socket.getSocket();
      if (socket == null) return;

      // Join comment room with the stored taskId
      socket.emit('join_comment', {'taskId': _currentTaskId!});
      print('Joined comment room for task: $_currentTaskId');

      // Remove any existing listeners first
      _removeSocketListeners();

      // Listen for new comments
      socket.on('new_comment', _handleNewComment);

      // Listen for comment events (optional)
      socket.on('comment_deleted', _handleCommentDeleted);
      socket.on('comment_updated', _handleCommentUpdated);

      // Handle reconnection - Use the stored taskId
      socket.on('connect', _handleSocketConnect);

      _isListening = true;
    } catch (e) {
      print('Error setting up socket listener: $e');
    }
  }

  void _handleSocketConnect(dynamic data) {
    print('Socket reconnected, rejoining comment room');
    if (_currentTaskId != null) {
      final socket = _socket.getSocket();
      socket?.emit('join_comment', {'taskId': _currentTaskId!});
    }
  }

  void _handleNewComment(dynamic data) {
    print('--bắt đầu xử lý khi có comment mởi dtata');
    print(data);
    try {
      if (data != null && _controller != null && !_controller!.isClosed) {
        final comment = CommentEntity.fromJson(data as Map<String, dynamic>);
        print(comment.parentId);
        _controller!.add(comment);
        print('New comment received: ${comment.parentId}');
      }
    } catch (e) {
      print('Error handling new comment: $e');
    }
  }

  void _handleCommentDeleted(dynamic data) {
    print('Comment deleted: $data');
    // Add your logic here if needed
  }

  void _handleCommentUpdated(dynamic data) {
    print('Comment updated: $data');
    // Add your logic here if needed
  }

  void _cleanupListener() {
    _removeSocketListeners();
    _isListening = false;
  }

  void _removeSocketListeners() {
    try {
      final socket = _socket.getSocket();
      if (socket != null) {
        socket.off('new_comment', _handleNewComment);
        socket.off('comment_deleted', _handleCommentDeleted);
        socket.off('comment_updated', _handleCommentUpdated);
        socket.off('connect', _handleSocketConnect);
      }
    } catch (e) {
      print('Error removing socket listeners: $e');
    }
  }

  @override
  Future<void> leaveCommentRoom(String taskId) async {
    try {
      final socket = _socket.getSocket();
      if (socket != null && socket.connected) {
        socket.emit('leave_comment', {'taskId': taskId});
        print('Left comment room for task: $taskId');
      }
    } catch (e) {
      print('Error leaving comment room: $e');
    }
  }

  @override
  void dispose() {
    print('Disposing CommentRemoteDataSource');

    // Leave current room if any
    if (_currentTaskId != null) {
      leaveCommentRoom(_currentTaskId!);
    }

    // Remove all socket listeners
    _removeSocketListeners();

    // Close stream controller
    if (_controller != null && !_controller!.isClosed) {
      _controller!.close();
    }

    _controller = null;
    _currentTaskId = null;
    _isListening = false;
  }

  Future<void> sendCommentViaSocket(
      {required String taskId,
      required String content,
      required String userId,
      String? parentId}) async {
    try {
      final socket = _socket.getSocket();
      if (socket == null || !socket.connected) {
        throw Exception('Socket not connected');
      }

      print('PARENT ở data $parentId');

      socket.emit('create_comment', {
        'task_id': taskId,
        'content': content,
        'user_id': userId,
        'parentId': parentId
      });

      print('Sent comment via socket');
    } catch (e) {
      print('Error sending comment via socket: $e');
      throw Exception('Failed to send comment via socket: $e');
    }
  }

  // Rest of your methods...
  @override
  Future<List<CommentEntity>> fetchComments(String taskId) async {
    try {
      if (taskId.isEmpty) {
        throw Exception('TaskId cannot be empty');
      }

      final response = await _dioClient.get('/tasks/$taskId/comments');

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final dataRaw = response.data as Map<String, dynamic>;
      final data = dataRaw['data'] as List?;

      if (data == null) {
        return <CommentEntity>[];
      }

      print(data);

      return data
          .map((json) => CommentEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching comments: $e');
      throw Exception('Failed to fetch comments: $e');
    }
  }

  @override
  Future<CommentModel> sendComment(
      String taskId, String content, String userId) async {
    try {
      if (taskId.isEmpty) {
        throw Exception('TaskId cannot be empty');
      }
      if (content.trim().isEmpty) {
        throw Exception('Comment content cannot be empty');
      }

      final response = await _dioClient.post('/tasks/$taskId/comments', data: {
        'content': content.trim(),
      });

      if (response.data == null) {
        throw Exception('No response from server');
      }

      final dataRaw = response.data as Map<String, dynamic>;
      final commentData = dataRaw['data'] as Map<String, dynamic>;

      return CommentModel.fromJson(commentData);
    } catch (e) {
      print('Error sending comment: $e');
      throw Exception('Failed to send comment: $e');
    }
  }
}
