import 'dart:async';
import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';
import 'package:to_do/features/notifications/domain/usecase/delete_notification_usecase.dart';
import 'package:to_do/features/notifications/domain/usecase/fetch_notification_usecase.dart';
import 'package:to_do/features/notifications/domain/usecase/listen_notification_stream.dart';
import 'package:to_do/features/notifications/domain/usecase/mark_read_notification_usecase.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_event.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FetchNotificationUsecase _fetchNotificationUsecase;
  final MarkReadNotificationUsecase _markReadNotificationUsecase;
  final ListenNotificationStream _listenNotificationStream;
  final DeleteNotificationUsecase _deleteNotificationUsecase;

  StreamSubscription<NotificationEntity>? _subscription;
  List<NotificationEntity> notifications = [];

  NotificationBloc(
    this._listenNotificationStream,
    this._fetchNotificationUsecase,
    this._markReadNotificationUsecase,
    this._deleteNotificationUsecase,
  ) : super(NotificationInitial()) {
    on<FetchNotification>(_onFetchNotification);
    on<SetLoading>(_onSetLoading);
    on<MarkReadEvent>(_onMarkReadNotification);
    on<DeleteNotification>(_onDeleteNotification);
    on<StartListeningNotifications>(_onStartListeningNotifications);
    on<StopListeningNotifications>(_onStopListeningNotifications);
    on<NewNotificationReceived>(_onNewNotificationReceived);
  }

  //  FIXED: Use emit.forEach for proper stream handling
  Future<void> _onStartListeningNotifications(
    StartListeningNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    // Cancel any existing subscription
    await _subscription?.cancel();
    
    // Use emit.forEach for proper stream handling in BLoC
    await emit.forEach<NotificationEntity>(
      _listenNotificationStream.execute(event.userId),
      onData: (newNotification) {
        // Add new notification to the beginning of the list
        final currentList = [...notifications];
        notifications = [newNotification, ...currentList];
        
        // Return the new state
        return NotificationLoadedSuccess(notifications: notifications);
      },
      onError: (error, stackTrace) {
        print("Error receiving notification: $error");
        return NotificationError(error.toString());
      },
    );
  }

  // Alternative approach: Handle via separate event
  void _onStopListeningNotifications(
    StopListeningNotifications event,
    Emitter<NotificationState> emit,
  ) {
    _subscription?.cancel();
    _subscription = null;
  }

  void _onNewNotificationReceived(
    NewNotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    final currentList = [...notifications];
    notifications = [event.notification, ...currentList];
    emit(NotificationLoadedSuccess(notifications: notifications));
  }

  Future<void> _onFetchNotification(
    FetchNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      print('Starting to fetch notifications...');
      
      final fetchedNoti = await _fetchNotificationUsecase.execute();
      
      print('FETCH NOTI O BLOC: $fetchedNoti');
      print('Type of fetchedNoti: ${fetchedNoti.runtimeType}');
      print('Length: ${fetchedNoti?.length ?? 'null'}');
      
      if (fetchedNoti == null) {
        print('Received null notifications');
        notifications = [];
        emit(NotificationLoadedSuccess(notifications: notifications));
        return;
      }
      
      if (fetchedNoti.isEmpty) {
        print('Received empty notifications list');
        notifications = fetchedNoti;
        emit(NotificationLoadedSuccess(notifications: notifications));
        return;
      }
      
      print('Successfully received ${fetchedNoti.length} notifications');
      notifications = fetchedNoti;
      emit(NotificationLoadedSuccess(notifications: notifications));
      
    } catch (error, stackTrace) {
      print('Error in _onFetchNotification: $error');
      print('Stack trace: $stackTrace');
      emit(NotificationError(error.toString()));
    }
  }

  void _onSetLoading(SetLoading event, Emitter<NotificationState> emit) {
    emit(NotificationLoading());
  }

  Future<void> _onMarkReadNotification(
    MarkReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Don't emit loading for mark read - it's better UX to update immediately
      final result = await _markReadNotificationUsecase.execute(event.id);

      if (result) {
        // Find and update the notification
        final updatedNotifications = notifications.map((notification) {
          if (notification.id == event.id) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        notifications = updatedNotifications;
        emit(NotificationLoadedSuccess(notifications: notifications));
      } else {
        emit(NotificationError('Failed to mark notification as read'));
      }
    } catch (error) {
      emit(NotificationError(error.toString()));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final result = await _deleteNotificationUsecase
          .deleteNotification(event.notificationId);

      if (result) {
        if (event.notificationId != null && event.notificationId!.isNotEmpty) {
          // Delete single notification
          notifications = notifications
              .where((item) => item.id != event.notificationId)
              .toList();
        } else {
          // Delete all notifications
          notifications.clear();
        }
        
        emit(NotificationLoadedSuccess(notifications: notifications));
      } else {
        emit(NotificationError('Failed to delete notification'));
      }
    } catch (error) {
      emit(NotificationError(error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}