import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';

class TaskInProjectCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onMarks;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool? isCurrent;
  final bool? isHorizontal;

  const TaskInProjectCard(
      {super.key,
      required this.task,
      this.isCurrent,
      this.onDelete,
      this.onEdit,
      this.onMarks,
      this.isHorizontal});

  @override
  Widget build(BuildContext context) {
    final bool isCurrentTask = isCurrent ?? false;
    final bool isOverdue = Utils.isOverdue(task.dueDate!);
    final bool isCompleted = task.status == 'Completed';

    return GestureDetector(
      onTap: () => context.pushNamed('taskDetailScreen', extra: task.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: _buildCardDecoration(isCurrentTask, isOverdue, isCompleted),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.pushNamed('taskDetailScreen', extra: task.id),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isCurrentTask),
                  const SizedBox(height: 12),
                  _buildContent(context, isCurrentTask),
                  const SizedBox(height: 16),
                  _buildFooter(context, isCurrentTask, isOverdue, isCompleted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(
      bool isCurrentTask, bool isOverdue, bool isCompleted) {
    Color cardColor;

    if (isCurrentTask) {
      cardColor = Colors.indigo.shade600;
    } else if (isCompleted) {
      cardColor = const Color.fromARGB(255, 217, 249, 219);
    } else if (isOverdue) {
      cardColor = const Color.fromARGB(255, 252, 225, 228);
    } else {
      cardColor =
          Utils.mappingStatusColors[task.status] ?? Colors.grey.shade100;
    }

    return BoxDecoration(
      gradient: isCurrentTask
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.shade600,
                Colors.indigo.shade800,
              ],
            )
          : null,
      color: isCurrentTask ? null : cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color:
              isCurrentTask ? Colors.indigo.withOpacity(0.3) : Colors.black12,
          blurRadius: isCurrentTask ? 12 : 6,
          offset: const Offset(0, 4),
          spreadRadius: isCurrentTask ? 2 : 0,
        ),
      ],
      border: isCurrentTask
          ? null
          : Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCurrentTask) {
    return Row(
      children: [
        Expanded(
          child: Text(
            task.title,
            style: GoogleFonts.inter(
              color: isCurrentTask ? Colors.white : Colors.grey.shade800,
              fontSize: isCurrentTask ? 20 : 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildMoreButton(isCurrentTask, context),
      ],
    );
  }

  Widget _buildMoreButton(bool isCurrentTask, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentTask
            ? Colors.white.withOpacity(0.2)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () {
          print('Hello - Press More Button');
          _showOptionsBottomSheet(context);
        },
        icon: Icon(
          Icons.more_horiz,
          color: isCurrentTask ? Colors.white : Colors.grey.shade600,
          size: 20,
        ),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isCurrentTask) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.description.isNotEmpty) ...[
          Text(
            task.description,
            style: GoogleFonts.inter(
              color: isCurrentTask
                  ? Colors.white.withOpacity(0.9)
                  : Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
        ],
        _buildPriorityAndDate(isCurrentTask),
      ],
    );
  }

  Widget _buildPriorityAndDate(bool isCurrentTask) {
    return Row(
      children: [
        _buildPriorityChip(isCurrentTask),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: isCurrentTask
                    ? Colors.white.withOpacity(0.8)
                    : Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                Utils.formatDateTime(task.dueDate),
                style: GoogleFonts.inter(
                  color: isCurrentTask
                      ? Colors.white.withOpacity(0.9)
                      : Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showPersons(
    BuildContext context,
    TaskEntity task, {
    String title = 'Phân công',
    String content = 'Saved successfully',
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style: GoogleFonts.roboto(fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: task.assignees.length,
              itemBuilder: (context, index) {
                final member = task.assignees[index];
                print("'Member $index' ${member.name}");
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildSelectedUser(user: member),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Close",
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedUser({
    required UserEntity user,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.network(
              user.avatar,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return CircleAvatar(
                  child: Icon(Icons.person),
                );
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(user.name, style: GoogleFonts.robotoFlex(fontSize: 15)),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(bool isCurrentTask) {
    final priorityColor =
        Utils.mappingColors[task.priority] ?? Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentTask
            ? Colors.white.withOpacity(0.2)
            : priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentTask
              ? Colors.white.withOpacity(0.3)
              : priorityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        task.priority,
        style: GoogleFonts.inter(
          color: isCurrentTask ? Colors.white : priorityColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isCurrentTask, bool isOverdue,
      bool isCompleted) {
    return Row(
      children: [
        _buildAssigneeInfo(context, isCurrentTask),
        const Spacer(),
        _buildStatusIndicator(isCompleted, isOverdue),
      ],
    );
  }

  Widget _buildAssigneeInfo(BuildContext context, bool isCurrentTask) {
    return GestureDetector(
      onTap: () => showPersons(context, task),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCurrentTask
              ? Colors.white.withOpacity(0.15)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_rounded,
              size: 16,
              color: isCurrentTask
                  ? Colors.white.withOpacity(0.8)
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              '${task.assignees.length} ${task.assignees.length == 1 ? 'person' : 'people'}',
              style: GoogleFonts.inter(
                color: isCurrentTask
                    ? Colors.white.withOpacity(0.9)
                    : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isCompleted, bool isOverdue) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.green.shade500,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 16,
        ),
      );
    } else if (isOverdue) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red.shade500,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.priority_high,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
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
            _buildBottomSheetOption(
              context: context,
              icon: Icons.edit_rounded,
              title: 'Edit Task',
              onTap: onEdit,
            ),
            _buildBottomSheetOption(
              context: context,
              icon: Icons.check_circle_rounded,
              title: 'Mark as Done',
              onTap: onMarks,
            ),
            _buildBottomSheetOption(
              context: context,
              icon: Icons.delete_rounded,
              title: 'Delete Task',
              onTap: onDelete,
              isDestructive: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption(
      {required IconData icon,
      required String title,
      required VoidCallback? onTap,
      bool isDestructive = false,
      required BuildContext context}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: isDestructive ? Colors.red : Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) {
          onTap.call();
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// Custom X Checkbox widget nếu bạn chưa có
class CustomXCheckbox extends StatelessWidget {
  final bool value;

  const CustomXCheckbox({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: value ? Colors.red.shade500 : Colors.transparent,
        border: Border.all(
          color: Colors.red.shade500,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: value
          ? const Icon(
              Icons.close,
              color: Colors.white,
              size: 16,
            )
          : null,
    );
  }
}
