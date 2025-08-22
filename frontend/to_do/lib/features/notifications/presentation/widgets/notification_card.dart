import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final void Function(dynamic)? onTap;
  final VoidCallback? onLongPress; 

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onLongPress
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: InkWell(
        onLongPress: onLongPress,
        onTap: () {
          if (onTap != null) {
            onTap!(notification); // truyền dữ liệu nếu cần
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white :  const Color.fromARGB(255, 210, 226, 251) ,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading Icon
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: getColorByType(notification.type).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  getIconByType(notification.type),
                  color: getColorByType(notification.type),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Text section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    //const SizedBox(height: 4),
                    // Time
                    Text(
                      Utils.formatDateTime(notification.createdAt),
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      notification.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData getIconByType(String type) {
    switch (type) {
      case 'comment':
        return Icons.comment_outlined;
      case 'task':
        return Icons.task_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color getColorByType(String type) {
    switch (type) {
      case 'comment':
        return Colors.blueAccent;
      case 'task':
        return Colors.green;
      default:
        return Colors.orangeAccent;
    }
  }
}
