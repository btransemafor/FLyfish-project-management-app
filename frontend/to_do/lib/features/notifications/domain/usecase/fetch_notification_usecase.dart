import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';
import 'package:to_do/features/notifications/domain/repositories/notification_repository.dart';

class FetchNotificationUsecase {
  final NotificationRepository _repo; 
  const FetchNotificationUsecase(this._repo); 

  Future<List<NotificationEntity>> execute() async {
    try {
      print('[USECASE] Starting to fetch notifications...');
      
      final data = await _repo.fetchNotifications();
      
      print('[USECASE] Raw data from repo: $data');
      print('[USECASE] Data type: ${data.runtimeType}');
      print('[USECASE] Data length: ${data?.length ?? 'null'}');
      
      if (data == null) {
        print('[USECASE] Repository returned null, returning empty list');
        return <NotificationEntity>[];
      }
      
      if (data.isEmpty) {
        print('[USECASE] Repository returned empty list');
        return <NotificationEntity>[];
      }
      
      print('[USECASE] Successfully got ${data.length} notifications');
      return data;
      
    } catch (e, stackTrace) {
      print('[USECASE] Error caught: $e');
      print('[USECASE] Stack trace: $stackTrace');
      rethrow; // Re-throw to see the original error
    }
  }
}