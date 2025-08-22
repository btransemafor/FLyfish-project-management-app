import 'package:to_do/features/notifications/domain/repositories/notification_repository.dart';

class DeleteNotificationUsecase {
  final NotificationRepository _repo; 
  const DeleteNotificationUsecase(this._repo); 
  Future<bool> deleteNotification([String? notificationId]) async {
    return await _repo.deleteNotification(notificationId);
  }
}