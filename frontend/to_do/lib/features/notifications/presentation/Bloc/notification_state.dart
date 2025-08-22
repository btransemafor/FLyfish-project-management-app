import 'package:equatable/equatable.dart';
import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  @override    
  List<Object> get props => [];
}


class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoadedSuccess extends NotificationState {
  final List<NotificationEntity> notifications; 
  NotificationLoadedSuccess({this.notifications = const []}); 
  @override    
  List<Object> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message; 
  NotificationError(this.message); 
  @override    
  List<Object> get props => [message];
}

