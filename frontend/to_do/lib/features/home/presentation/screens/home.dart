import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_state.dart';
import 'package:to_do/features/home/presentation/bloc/bottom_nav_cubit.dart';
import 'package:to_do/features/home/presentation/screens/home_screen.dart';
import 'package:to_do/features/home/presentation/widgets/custom_bottom_navigation.dart';
import 'package:to_do/features/home/presentation/widgets/custom_text_field.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_bloc.dart';
import 'package:to_do/features/notifications/presentation/Bloc/notification_state.dart';
import 'package:to_do/features/notifications/presentation/screens/notification_screen.dart';
import 'package:to_do/features/profile/presentation/screens/profile_screen.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/projects/presentation/bloc/project_event.dart';
import 'package:to_do/features/projects/presentation/bloc/project_state.dart';
import 'package:to_do/other/other_screen.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    OtherScreen(),
    NotificationScreen(),
    ProfileScreen()
  ];

  static const List<IconData> _items = [
    Icons.home_rounded,
    Icons.task_alt_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded
  ];

  static const List<String> _labels = [
    'Trang chủ',
    'Nhiệm vụ',
    'Thông báo',
    'Cá nhân'
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BottomNavCubit()),
      ],
      child: BlocBuilder<BottomNavCubit, int>(
        builder: (context, selectedIndex) {
          return Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    bottom: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: _pages[selectedIndex],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, state) {
                        if (state is NotificationLoadedSuccess) {
                          final countUnRead = state.notifications
                              .where((item) => item.isRead == false)
                              .toList()
                              .length;
                          // filter noti unread

                          return CustomBottomNavigation(
                              onTap: (index) => context
                                  .read<BottomNavCubit>()
                                  .changeIndex(index),
                              selectedIndex: selectedIndex,
                              listIcon: _items,
                              listLabel: _labels,
                              unreadCount: countUnRead);
                        }

                        return CustomBottomNavigation(
                          onTap: (index) =>
                              context.read<BottomNavCubit>().changeIndex(index),
                          selectedIndex: selectedIndex,
                          listIcon: _items,
                          listLabel: _labels,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 28,
                    bottom: 55,
                    child: _buildFloatingActionButton(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 0),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 32, 38, 89),
              Color.fromARGB(255, 48, 54, 113),
              Color.fromARGB(255, 15, 38, 247),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onAddButtonPressed(context),
            borderRadius: BorderRadius.circular(28),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  void _onAddButtonPressed(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (bottomSheetContext, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  // Pass the parent context to access ProjectBloc
                  child: ContentModelCreateProject(parentContext: context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentModelCreateProject extends StatefulWidget {
  final BuildContext parentContext; // Context from Home to access ProjectBloc

  const ContentModelCreateProject({super.key, required this.parentContext});

  @override
  State<ContentModelCreateProject> createState() =>
      _ContentModelCreateProjectState();
}

class _ContentModelCreateProjectState extends State<ContentModelCreateProject> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late FocusNode _nameFocusNode;
  late FocusNode _descriptionFocusNode;
  final _formKey = GlobalKey<FormState>();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _nameFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  String _mapErrorToMessage(String error) {
    if (error.contains('DioError') || error.contains('Connection')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else if (error.contains('Unauthorized')) {
      return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
    }
    return 'Đã xảy ra lỗi: $error';
  }

  void _handleCreateProject() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();

      final authState = widget.parentContext.read<AuthBloc>().state;

      if (authState is GetLocalUserSuccess) {
        final user = authState.user;

        // Use parentContext to access ProjectBloc
        widget.parentContext.read<ProjectBloc>().add(
              CreateProject(
                description: description,
                endDate: endDate,
                leader_id: user.userId,
                name: name,
                startDate: startDate,
                status: 'OnGoing',
              ),
            );

        // Listen for ProjectBloc state
        widget.parentContext
            .read<ProjectBloc>()
            .stream
            .firstWhere(
                (state) => state is ProjectSuccess || state is ProjectError)
            .then((state) {
          if (state is ProjectSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dự án "$name" đã được tạo thành công!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
            Navigator.pop(context); // Close bottom sheet
          } else if (state is ProjectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_mapErrorToMessage(state.error)),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });

        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Không thể tạo dự án vì chưa có thông tin người dùng.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _nameFocusNode.unfocus();
    _descriptionFocusNode.unfocus();
    setState(() {
      startDate = null;
      endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tạo Dự Án Mới',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Điền thông tin để tạo dự án mới của bạn',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Tên dự án',
              controller: _nameController,
              focusNode: _nameFocusNode,
              nextFocusNode: _descriptionFocusNode,
              labelColor: Colors.blue.shade700,
              focusedBorderColor: Colors.blue.shade500,
              prefixIcon: const Icon(Icons.folder_outlined),
              required: true,
              placeholder: 'Nhập tên dự án của bạn...',
              helperText: 'Tên dự án nên ngắn gọn và dễ nhớ',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên dự án';
                }
                if (value.trim().length < 3) {
                  return 'Tên dự án phải có ít nhất 3 ký tự';
                }
                if (value.trim().length > 50) {
                  return 'Tên dự án không được vượt quá 50 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Mô tả dự án',
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              labelColor: Colors.blue.shade700,
              focusedBorderColor: Colors.blue.shade500,
              prefixIcon: const Icon(Icons.description_outlined),
              maxLines: 4,
              minLines: 3,
              maxLength: 500,
              placeholder: 'Mô tả chi tiết về dự án của bạn...',
              helperText: 'Mô tả sẽ giúp bạn và team hiểu rõ mục tiêu dự án',
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value != null &&
                    value.trim().isNotEmpty &&
                    value.trim().length < 10) {
                  return 'Mô tả phải có ít nhất 10 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ProjectDateRangePicker(
              onStartDateChanged: (d) => setState(() => startDate = d),
              onEndDateChanged: (d) => setState(() => endDate = d),
            ),
            const SizedBox(height: 16),
            BlocBuilder<ProjectBloc, ProjectState>(
              bloc:
                  widget.parentContext.read<ProjectBloc>(), // Use parentContext
              builder: (context, state) {
                if (state is ProjectLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ProjectError) {
                  return Text(
                    _mapErrorToMessage(state.error),
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Xóa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _handleCreateProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: BlocBuilder<ProjectBloc, ProjectState>(
                      bloc: widget.parentContext
                          .read<ProjectBloc>(), // Use parentContext
                      builder: (context, state) {
                        if (state is ProjectLoading) {
                          return const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tạo Dự Án',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectDateRangePicker extends StatefulWidget {
  final void Function(DateTime?) onStartDateChanged;
  final void Function(DateTime?) onEndDateChanged;

  const ProjectDateRangePicker({
    super.key,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProjectDateRangePickerState createState() => _ProjectDateRangePickerState();
}

class _ProjectDateRangePickerState extends State<ProjectDateRangePicker>
    with SingleTickerProviderStateMixin {
  DateTime? _startDate;
  DateTime? _endDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Select Date Range',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Start Date Button
          _buildDateButton(
            label: 'Start Date',
            date: _startDate,
            onPressed: () => _selectStartDate(context),
            icon: Icons.calendar_today_outlined,
            color: Colors.blue,
          ),

          const SizedBox(height: 12),

          // End Date Button
          _buildDateButton(
            label: 'End Date',
            date: _endDate,
            onPressed: () => _selectEndDate(context),
            icon: Icons.event_outlined,
            color: Colors.green,
          ),

          // Date Range Display
          if (_startDate != null && _endDate != null) ...[
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.date_range, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(_startDate!)} → ${_formatDate(_endDate!)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: date != null ? color.withOpacity(0.3) : Colors.grey[300]!,
          width: 1.5,
        ),
        gradient: date != null
            ? LinearGradient(
                colors: [
                  color.withOpacity(0.05),
                  color.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: date != null
                        ? color.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: date != null ? color : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date != null ? _formatDate(date) : 'Select $label',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: date != null
                              ? Colors.grey[800]
                              : Colors.grey[500],
                          fontWeight:
                              date != null ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _endDate ?? DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
        // Reset end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(selectedDate)) {
          _endDate = null;
          _animationController.reset();
        }
      });
      widget.onStartDateChanged(selectedDate);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
      });
      widget.onEndDateChanged(selectedDate);

      // Trigger animation when both dates are selected
      if (_startDate != null) {
        _animationController.forward();
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Placeholder screens và modal (giống như trước)
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Tasks Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class CreateTaskModal extends StatelessWidget {
  const CreateTaskModal({super.key});
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
