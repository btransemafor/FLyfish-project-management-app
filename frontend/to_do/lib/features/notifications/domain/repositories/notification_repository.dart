import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> fetchNotifications(); 
  Future<bool> markReadNotification(String id); 
  Stream<NotificationEntity> listenNotification([String? user_id]);
  Future<bool> deleteNotification([String? notificationId]); 
   
}