import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/common/custom_loading.dart';
import 'package:to_do/features/notifications/domain/entities/notification_entity.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_event.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_state.dart';
import 'package:to_do/features/notifications/presentation/widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    context.read<NotificationBloc>().add(FetchNotification());
  }

  void _onNotificationTap(NotificationEntity notification) {
    debugPrint('[NOTIFICATION TYPE]: ${notification.type}');
    
    // Mark as read
    context.read<NotificationBloc>().add(MarkReadEvent(notification.id));
    
    // Navigate based on type
    _navigateBasedOnType(notification);
  }

  void _navigateBasedOnType(NotificationEntity notification) {
    switch (notification.type) {
      case 'comment':
      case 'task':
        context.pushNamed('taskDetailScreen', extra: notification.relatedId);
        break;
      // Add more cases as needed
      default:
        debugPrint('Unknown notification type: ${notification.type}');
    }
  }

  Future<void> _handleRefresh() async {
    _fetchNotifications();
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showNotificationOptions(BuildContext context, NotificationEntity notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomContext) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: Text(
                  notification.isRead ? 'Đánh dấu chưa đọc' : 'Đánh dấu đã đọc',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(bottomContext);
                  context.read<NotificationBloc>().add(
                   
                       MarkReadEvent(notification.id)
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Xóa thông báo',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(bottomContext);
                  _showDeleteConfirmation(context, notification);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, NotificationEntity notification) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Xóa thông báo',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa thông báo này?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Hủy',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<NotificationBloc>().add(
                  DeleteNotification(notificationId: notification.id),
                );
              },
              child: Text(
                'Xóa',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Xóa tất cả thông báo',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa tất cả thông báo? Hành động này không thể hoàn tác.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Hủy',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<NotificationBloc>().add(DeleteNotification());
              },
              child: Text(
                'Xóa tất cả',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const ShimmerWidget.circular(width: 60, height: 60),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rectangular(height: 30, width: 120),
                const SizedBox(height: 8),
                ShimmerWidget.rectangular(height: 15, width: double.infinity),
                const SizedBox(height: 6),
                ShimmerWidget.rectangular(height: 25, width: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildShimmerItem(),
        childCount: 5,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi tải thông báo!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.red.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchNotifications,
                child: Text(
                  'Thử lại',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 60,
                  color: Colors.blue.shade300,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Chưa có thông báo nào',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mọi thông báo mới sẽ xuất hiện tại đây.\nHãy kiên nhẫn nhé!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationEntity> notifications) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == notifications.length - 1 ? 150 : 8,
              left: 12,
              right: 12,
              top: 8,
            ),
            child: NotificationCard(
              onLongPress: () => _showNotificationOptions(context, notification),
              onTap:(noti) =>  _onNotificationTap(noti),
              notification: notification,
            ),
          );
        },
        childCount: notifications.length,
      ),
    );
  }

  Widget _buildNotificationContent() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        debugPrint('CURRENT NOTIFICATION STATE: $state');
        
        if (state is NotificationLoading) {
          return _buildLoadingState();
        } else if (state is NotificationError) {
          return _buildErrorState(state.message ?? 'Unknown error occurred');
        } else if (state is NotificationLoadedSuccess) {
          if (state.notifications.isEmpty) {
            return _buildEmptyState();
          } else {
            return _buildNotificationsList(state.notifications);
          }
        }

        return const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDeleteAllButton() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoadedSuccess && state.notifications.isNotEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.notifications.length} thông báo',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: _showDeleteAllConfirmation,
                    child: Text(
                      'Xóa tất cả',
                      style: GoogleFonts.poppins(color: Colors.red,   fontSize: 12,),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: RefreshIndicator(
        backgroundColor: Colors.blue.shade900,
        strokeWidth: 2.0,
        displacement: 40,
        color: Colors.white,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Enables pull-to-refresh even with empty content
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.grey.shade100,
              automaticallyImplyLeading: false,
              title: Text(
                'Thông báo',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              floating: true,
              snap: true,
            ),
            _buildDeleteAllButton(),
            _buildNotificationContent(),
          ],
        ),
      ),
    );
  }
}