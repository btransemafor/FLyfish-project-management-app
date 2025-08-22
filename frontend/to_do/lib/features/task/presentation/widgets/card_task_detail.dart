import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/users/presentation/widgets/user_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardTaskDetail extends StatefulWidget {
  final TaskEntity task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(BuildContext context, UserEntity user)? onRemoveUser;
  final bool showActions;

  const CardTaskDetail(
    this.task, {
    super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onRemoveUser,
    this.showActions = true,
  });

  @override
  State<CardTaskDetail> createState() => _CardTaskDetailState();
}

class _CardTaskDetailState extends State<CardTaskDetail> {
  bool isExpand = false;

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade600;
      case 'medium':
        return Colors.orange.shade600;
      case 'low':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Icons.keyboard_double_arrow_up_rounded;
      case 'medium':
        return Icons.keyboard_arrow_up_rounded;
      case 'low':
        return Icons.keyboard_arrow_down_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return Colors.green.shade600;
      case 'in progress':
      case 'doing':
        return Colors.blue.shade600;
      case 'pending':
      case 'todo':
        return Colors.orange.shade600;
      case 'cancelled':
      case 'canceled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'done':
        return Icons.check_circle_rounded;
      case 'in progress':
      case 'doing':
        return Icons.sync_rounded;
      case 'pending':
      case 'todo':
        return Icons.radio_button_unchecked_rounded;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else if (difference.inDays > 1 && difference.inDays <= 7) {
      return 'In ${difference.inDays} days';
    } else if (difference.inDays < -1 && difference.inDays >= -7) {
      return '${difference.inDays.abs()} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  bool _isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate) &&
        widget.task.status.toLowerCase() != 'completed' &&
        widget.task.status.toLowerCase() != 'done';
  }

  // OnEdit
  void onEdit() {}
  void _showMemberDialog(List<UserEntity> user, BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Thành viên Thực hiện Task',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Member List
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    itemCount: user.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return UserCard(
                        onDelete: (context) {
                          print('[Thực hiện xóa user: ${user[index].name}]');
                          // Gọi callback onRemoveUser để thông báo ra parent
                          widget.onRemoveUser?.call(context, user[index]);
                          dialogContext.pop(true);
                        },
                        user[index],
                        isHidden: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        // Thêm hành động khác ở đây nếu cần
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Đóng',
                          style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = _isOverdue(widget.task.dueDate!);
    final priorityColor = _getPriorityColor(widget.task.priority);
    final statusColor = _getStatusColor(widget.task.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isOverdue
              ? const Color.fromARGB(255, 255, 236, 236)
              : theme.dividerColor.withOpacity(0.12),
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title + Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority indicator
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getPriorityIcon(widget.task.priority),
                        size: 16,
                        color: priorityColor,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              decoration: widget.task.status.toLowerCase() ==
                                      'completed'
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Priority label
                          Text(
                            '${widget.task.priority.toUpperCase()} PRIORITY',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: priorityColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    if (widget.showActions)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: theme.hintColor,
                        ),
                        offset: const Offset(0, 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded,
                                    size: 18, color: theme.hintColor),
                                const SizedBox(width: 12),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded,
                                    size: 18, color: Colors.red.shade600),
                                const SizedBox(width: 12),
                                Text('Delete',
                                    style:
                                        TextStyle(color: Colors.red.shade600)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              widget.onEdit?.call();
                              break;
                            case 'delete':
                              widget.onDelete?.call();
                              break;
                          }
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                if (widget.task.description.isNotEmpty) ...[
                  Text(
                    widget.task.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                    maxLines:
                        isExpand ? null : 3, // khi expand thì hiện toàn bộ
                    overflow: TextOverflow.ellipsis,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          isExpand = !isExpand;
                        });
                      },
                      child: Text(
                        isExpand ? 'View less' : 'View more',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  )
                ],

                // Status and Due Date Row
                Row(
                  children: [
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(widget.task.status),
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.task.status.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Due date
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? Colors.red.shade50
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOverdue
                              ? Colors.red.shade300
                              : theme.dividerColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.warning_rounded
                                : Icons.schedule_rounded,
                            size: 14,
                            color: isOverdue
                                ? Colors.red.shade600
                                : theme.hintColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(widget.task.dueDate!),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isOverdue
                                  ? Colors.red.shade600
                                  : theme.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Assignees section
                if (widget.task.assignees.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.people_rounded,
                        size: 16,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _showMemberDialog(widget.task.assignees, context);
                          },
                          child: SizedBox(
                            height: 32,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.task.assignees.length > 5
                                  ? 5
                                  : widget.task.assignees.length,
                              itemBuilder: (context, index) {
                                if (index == 4 &&
                                    widget.task.assignees.length > 5) {
                                  return Container(
                                    width: 32,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondary
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.secondary
                                            .withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+${widget.task.assignees.length - 4}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme.colorScheme.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final assignee = widget.task.assignees[index];
                                return Container(
                                  width: 32,
                                  height: 32,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.primaries[
                                            index % Colors.primaries.length]
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.primaries[
                                              index % Colors.primaries.length]
                                          .withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      assignee.name.isNotEmpty
                                          ? assignee.name[0].toUpperCase()
                                          : '?',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: Colors.primaries[
                                            index % Colors.primaries.length],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Creator
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 14,
                              color: theme.hintColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.task.creator.name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
