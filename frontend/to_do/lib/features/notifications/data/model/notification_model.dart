import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id , 
    required super.message, 
    required super.title, 
    required super.relatedId, 
    required super.createdAt, 
    required super.type, 
    required super.isRead
  }); 


  factory NotificationModel.fromJson(Map<String,dynamic> json) {
    return NotificationModel(
      id: json['id'], 
      message: json['message'] , 
      title: json['title'], 
      relatedId: json['relatedId'], 
      createdAt: DateTime.tryParse(json['createdAt']) ?? DateTime.now(), 
      type: json['type'] ?? 'No Type', 
      isRead: json['isRead']    
      );
  }

}