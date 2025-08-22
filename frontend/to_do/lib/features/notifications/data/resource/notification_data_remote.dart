import 'dart:async';

import 'package:dio/dio.dart';
import 'package:to_do/core/socket/socket_manager.dart';
import 'package:to_do/features/notifications/data/model/notification_model.dart';

abstract class NotificationDataRemote {
  Future<List<NotificationModel>> fetchListNotification();
  Future<bool> markReadNotification(String id);
  Stream<NotificationModel> listenNotification([String? user_id]);
  Future<bool> deleteNotification([String? notificationId]); 
}

class NotificationDataRemoteImpl extends NotificationDataRemote {
  final Dio dio;
  final SocketManager socketManager;
  NotificationDataRemoteImpl(this.dio, this.socketManager);

  @override
  Future<List<NotificationModel>> fetchListNotification() async {
    final response = await dio.get('/notifications');

    final dataRaw = response.data;
    print('[Notifications] ${dataRaw}');
    final data = dataRaw['data'] as List<dynamic>;
    return data.map((item) => NotificationModel.fromJson(item)).toList();
  }

  @override
  Future<bool> markReadNotification(String id) async {
    print('[Mark Read] $id');
    final response = await dio.get('/notifications/$id/mark-read');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Stream<NotificationModel> listenNotification([String? user_id]) {
    final controller = StreamController<NotificationModel>();

    final socket = socketManager.getSocket();
    if (socket == null) {
      controller.close();
      return controller.stream;
    }
    if (socket != null) {
      if (user_id == null) {
        // Event toàn app (không cần userId)
        socket!.on('notification:global', (data) {
          print('[Global Notification] $data');
        });
      } else {
        socket.emit('joinNotification', user_id); // phải gửi user_id
        print('Joined notification room: user_$user_id');
      }
    }

    socket.on('notification:new', (data) {
      try {
        final notification = NotificationModel.fromJson(data);
        controller.add(notification);
      } catch (e) {
        print('[Socket] Parse error: $e');
      }
    });

    return controller.stream;
  }

  @override    
  Future<bool> deleteNotification([String? notificationId]) async {
    final response = await dio.delete( notificationId != null  ? '/notifications/$notificationId' : '/notifications'); 

    if (response.statusCode == 200 ) {
      return true; 
    }
    return false; 
  }
}
