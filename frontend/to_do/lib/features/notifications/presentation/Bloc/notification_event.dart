/* import 'package:equatable/equatable.dart';
import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationEvent extends Equatable {
  @override    
  List<Object?> get props => []; 
}

class FetchNotification extends NotificationEvent {
  @override    
  List<Object> get props => []; 
}

class SetLoading extends NotificationEvent {
    @override    
  List<Object> get props => []; 
}

class MarkReadEvent extends NotificationEvent {
  final String id;
  MarkReadEvent(this.id);  
  @override    
  List<Object> get props => [id]; 
}

class NewNotificationEvent extends NotificationEvent {
  final NotificationEntity noti; 
  NewNotificationEvent(this.noti); 
  @override    
  List<Object> get props => [noti];
}

class StartListeningNotifications extends NotificationEvent {
  final String? userId; 
  StartListeningNotifications([this.userId]); 
  @override    
  List<Object?> get props => [userId];
}

class DeleteNotification extends NotificationEvent {
  final String? notificationId; 
  DeleteNotification([this.notificationId]); 
  @override    
  List<Object?> get props => [notificationId];
} */

import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationEvent {}

class FetchNotification extends NotificationEvent {}

class SetLoading extends NotificationEvent {}

class MarkReadEvent extends NotificationEvent {
  final String id;
  MarkReadEvent(this.id);
}

class MarkUnreadEvent extends NotificationEvent {
  final String id;
  MarkUnreadEvent(this.id);
}

class DeleteNotification extends NotificationEvent {
  final String? notificationId;
  DeleteNotification({this.notificationId});
}

class DeleteSingleNotification extends NotificationEvent {
  final String notificationId;
  DeleteSingleNotification(this.notificationId);
}

class StartListeningNotifications extends NotificationEvent {
  final String userId;
  StartListeningNotifications(this.userId);
}

class StopListeningNotifications extends NotificationEvent {}

class NewNotificationReceived extends NotificationEvent {
  final NotificationEntity notification;
  NewNotificationReceived(this.notification);
}