class NotificationEntity {
  final String id; 
  final String title; 
  final String message; 
  final String type; 
  final String relatedId; 
  final DateTime createdAt; 
  final bool isRead; 

  const NotificationEntity({
    required this.createdAt, 
    required this.id, 
    required this.message, 
    required this.relatedId, 
    required this.title, 
    required this.type, 
    required this.isRead
  }); 

   NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? relatedId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }


}