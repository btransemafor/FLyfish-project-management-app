
import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';

import '../repositories/notification_repository.dart';

class ListenNotificationStream {
  final NotificationRepository repository;
  ListenNotificationStream(this.repository);

  Stream<NotificationEntity> execute([String? user_id]) {
    return repository.listenNotification(user_id); 
  }
}