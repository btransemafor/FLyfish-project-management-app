// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/app_router.dart';
import 'package:to_do/core/common/custom_back_button.dart';
import 'package:to_do/core/utils/helpers/success.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/auth/presentation/widgets/custom_form_field.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/task/presentation/bloc/task_event.dart';
import 'package:to_do/features/task/presentation/bloc/task_state.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;
  const EditTaskScreen({super.key, required this.taskId});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String priority = '';
  DateTime dueDate = DateTime.now();
  TimeOfDay timeDate = TimeOfDay.fromDateTime(DateTime.now());
  TaskEntity? initialTask;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TaskBloc>().add(FetchTaskDetail(widget.taskId));
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskDetailFetchedSuccess) {
          final task = state.task;
          setState(() {
            initialTask = task;
          });
          _titleController.text = task!.title;
          _descriptionController.text = task!.description;
          setState(() {
            priority = task.priority;
            print('[priority]: $priority');
            dueDate = task.dueDate ?? DateTime.now();
            print('[DUE DATE]: ${Utils.formatDateTime(dueDate)}');
            timeDate = TimeOfDay.fromDateTime(dueDate);
          });
        } else if (state is TaskUpdatedSuccess) {
          context.pop(true);
          Future.microtask(() {
            SuccessHelper.showSuccess(
                context, 'Nhiệm vụ được cập nhật thành công', Colors.green);
          });
        }
      },
      child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.grey.shade100,
                expandedHeight: 50,
                centerTitle: true,
                title: Text(
                  'Chỉnh sửa nhiệm vụ',
                  style: GoogleFonts.openSans(
                      fontSize: 22, fontWeight: FontWeight.w600),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CustomBackButton(
                    onPress: () {
                      context.pop();
                    },
                  ),
                ),
              ),
              _buildFormEditTask()
            ],
          )),
    );
  }

  Widget _buildFormEditTask() {
    return SliverList(
        delegate: SliverChildListDelegate([
      // Padding wrapper cho toàn bộ form
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(),
            const SizedBox(height: 24),

            // Title Field
            _buildSectionTextFieldItem(
              'Tiêu đề',
              'Nhập tiêu đề task...',
              _titleController,
              Icons.title_rounded,
            ),
            const SizedBox(height: 20),

            // Description Field
            _buildSectionTextFieldItem(
              'Mô tả',
              'Nhập mô tả chi tiết...',
              _descriptionController,
              Icons.description_rounded,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            // Priority Section
            _buildPrioritySection(),
            const SizedBox(height: 20),
            // Due Date Section
            _buildDueDateSection(),
            const SizedBox(height: 32),
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      )
    ]));
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chỉnh sửa Task',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'Cập nhật thông tin task của bạn',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTextFieldItem(
    String label,
    String subLabel,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomFormField(
            label: subLabel,
            controller: controller,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag_rounded,
                color: Colors.orange.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Độ ưu tiên',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 'Low', 'Medium', 'High', 'Urgent'
          Row(
            children: [
              _buildPriorityChip('Low', Colors.green, priority == 'Low'),
              const SizedBox(width: 10),
              _buildPriorityChip('Medium', Colors.amber, priority == 'Medium'),
              const SizedBox(width: 10),
              _buildPriorityChip(
                  'High', Colors.deepOrange.shade400, priority == 'High'),
              const SizedBox(width: 10),
              _buildPriorityChip('Urgent',
                  const Color.fromARGB(255, 233, 18, 18), priority == 'Urgent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String label, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Handle priority selection
        setState(() {
          // Update priority logic here
          priority = label;
          print('[Prority changed], ${priority}');
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _buildDueDateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ngày hết hạn',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              // Show date picker
              _selectDate(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Utils.formatDateTime(dueDate),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save Button
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _handleSaveTask();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.save_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lưu thay đổi',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Cancel Button
        Container(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Text(
              'Hủy bỏ',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

// Helper methods
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Handle selected date
      // pick time
      final TimeOfDay? pickTime =
          await showTimePicker(context: context, initialTime: timeDate);
      if (pickTime != null) {
        final DateTime finalDueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickTime.hour,
          pickTime.minute,
        );

        setState(() {
          dueDate = finalDueDate;
          print('Selected fulldate: $dueDate');
        });
      } else {
        setState(() {
          dueDate = picked;
          print('Selected date: $picked');
        });
      }
    }
  }

  void _handleSaveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('Vui lòng nhập tiêu đề task'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    // Show Dialog

    final field = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'status': initialTask?.status ?? 'Low'
    };

    final updateField = initialTask!.diff(field);
    // Dispatch update event
    context
        .read<TaskBloc>()
        .add(UpdateTask(taskId: widget.taskId, updateField: updateField));
  }
}
