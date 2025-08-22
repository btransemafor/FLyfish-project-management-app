import 'package:to_do/features/notifications/domain/repositories/notification_repository.dart';

class MarkReadNotificationUsecase {
  final NotificationRepository _repo;
  const MarkReadNotificationUsecase(this._repo);

  Future<bool> execute(String id) async {
    return await _repo.markReadNotification(id);
  }
}
