import 'package:to_do/features/notifications/data/resource/notification_data_remote.dart';
import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';
import 'package:to_do/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataRemote _dataRemote;
  const NotificationRepositoryImpl(this._dataRemote);
  @override
  Future<List<NotificationEntity>> fetchNotifications() async {
    final data = await _dataRemote.fetchListNotification();
    print('[Noti ở repository] ${data}' ); 
    return data
        .map((model) => NotificationEntity(
            createdAt: model.createdAt,
            id: model.id,
            message: model.message,
            relatedId: model.relatedId,
            title: model.title,
            type: model.type,
            isRead: model.isRead))
        .toList();
  }

  @override   
  Future<bool> markReadNotification(String id) async {
    return await _dataRemote.markReadNotification(id); 
  }

  @override   
  Stream<NotificationEntity> listenNotification([String? user_id]) {
    return _dataRemote.listenNotification(user_id); 
  }

  @override   
  Future<bool> deleteNotification([String? notificationId]) async {
    return await _dataRemote.deleteNotification(notificationId); 
  }
}
