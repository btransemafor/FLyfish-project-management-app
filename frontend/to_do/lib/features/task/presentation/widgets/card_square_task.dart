import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';

// Centralized theme constants
class AppTheme {
  static const Color cardBackground = Color(0xFFB9F6CA); // Green shade
  static const Color shadowColor = Colors.black12;
  static const double cardPadding = 10.0;
  static const double titleFontSize = 18.0;
  static const double bodyFontSize = 12.0;
  static const double chipPaddingHorizontal = 10.0;
  static const double chipPaddingVertical = 3.0;
}

// Reusable PriorityChip widget
class PriorityChip extends StatelessWidget {
  final String priority;
  final Color? backgroundColor;
  final Color? borderColor;

  const PriorityChip({
    super.key,
    required this.priority,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.chipPaddingHorizontal,
        vertical: AppTheme.chipPaddingVertical,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        color: backgroundColor ?? Utils.mappingColors[priority] ?? Colors.grey,
        border: Border.all(
          width: 1,
          color:
              borderColor ?? Utils.mappingColorsBorder[priority] ?? Colors.grey,
        ),
      ),
      child: Text(
        priority,
        style: GoogleFonts.inter(
          fontSize: AppTheme.bodyFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Reusable AssigneeChip widget
class AssigneeChip extends StatelessWidget {
  final int assigneeCount;

  const AssigneeChip({super.key, required this.assigneeCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 16),
          const SizedBox(width: 10),
          Text(
            assigneeCount > 0
                ? '$assigneeCount ${assigneeCount == 1 ? 'person' : 'people'}'
                : 'No assignees',
            style: GoogleFonts.inter(
              color: Colors.grey.shade700,
              fontSize: AppTheme.bodyFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CardSquareTask extends StatelessWidget {
  final TaskEntity task;

  const CardSquareTask({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final bool isOverDue =
        task.dueDate != null && Utils.isOverdue(task.dueDate!);
    final isComplete = task.status == 'Completed';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isComplete ? AppTheme.cardBackground : isOverDue ? Colors.pink.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppTheme.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task title with semantics for accessibility
          Semantics(
            label: 'Task: ${task.title}',
            child: Text(
              task.title,
              style: GoogleFonts.alata(
                fontWeight: FontWeight.bold,
                fontSize: AppTheme.titleFontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          // Due date or no deadline
          Text(
            task.dueDate != null
                ? 'Due: ${Utils.formatDateTime(task.dueDate!)}'
                : 'No deadline',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: AppTheme.bodyFontSize,
                ),
          ),
          const SizedBox(height: 10),
          // Priority and assignee row
          Row(
            children: [
              PriorityChip(priority: task.priority),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          AssigneeChip(assigneeCount: task.assignees.length),

          const SizedBox(height: 10),
          // Overdue status
          if (isOverDue)
            Row(
              children: [
                const Icon(
                  Icons.sentiment_dissatisfied,
                  color: Color.fromARGB(255, 244, 12, 74),
                  size: 25,
                ),
                const SizedBox(width: 10),
                PriorityChip(
                  priority: 'Overdue',
                  backgroundColor: Colors.red.shade200,
                  borderColor: Colors.red,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
