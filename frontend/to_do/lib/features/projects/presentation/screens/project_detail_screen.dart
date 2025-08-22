import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/common/custom_app_bar.dart';
import 'package:to_do/core/common/custom_loading.dart';
import 'package:to_do/core/utils/helpers/success.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_state.dart';
import 'package:to_do/features/home/presentation/bloc/home_bloc.dart';
import 'package:to_do/features/home/presentation/bloc/home_event.dart';
import 'package:to_do/features/home/presentation/bloc/home_state.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/projects/presentation/bloc/project_event.dart';
import 'package:to_do/features/projects/presentation/bloc/project_state.dart';
import 'package:to_do/features/projects/presentation/widgets/project_detailed_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:to_do/features/task/presentation/bloc/task_event.dart';
import 'package:to_do/features/task/presentation/bloc/task_state.dart';
import 'package:to_do/features/task/presentation/screens/edit_task_screen.dart';
import 'package:to_do/features/task/presentation/widgets/status_task_card.dart';
import 'package:to_do/features/task/presentation/widgets/task_in_project_card.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with RouteAware, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Phương thức fetch dữ liệu ban đầu
  void _fetchInitialData() {
    Future.microtask(() {
      context.read<ProjectBloc>().add(FetchProjectById(widget.projectId));
    });

    Future.microtask(() {
      context.read<TaskBloc>().add(LoadTaskForAProject(widget.projectId));
    });
  }

  // Phương thức refresh dữ liệu
  void _refreshData() {
    context.read<ProjectBloc>().add(FetchProjectById(widget.projectId));
    context.read<TaskBloc>().add(LoadTaskForAProject(widget.projectId));
  }

  @override
  void didPopNext() {
    print('Quay lại màn hình ProjectDetail - Refresh data');
    _refreshData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Khi app được focus lại (từ background về foreground)
    if (state == AppLifecycleState.resumed) {
      print('App resumed - Refresh project detail data');
      _refreshData();
    }
  }

  // Alternative: Sử dụng WillPopScope để bắt sự kiện back
  Future<bool> _onWillPop() async {
    return true; // Cho phép pop
  }

  void deleteTask(String id, BuildContext context) async {
    // Hiển thị dialog và đợi kết quả trả về
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bạn có chắc chắn muốn xóa Task này không?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text('Không'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade500,
                              Colors.purple.shade500
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text('Có'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // Nếu người dùng chọn "Có" thì mới gọi bloc xóa
    if (confirm == true) {
      context.read<TaskBloc>().add(
            DeleteTaskById(
              id,
              TaskActionStatus.deleted, // Cờ để UI show snackbar
            ),
          );
    }
  }

  void showStatusDialog(BuildContext screenContext, TaskEntity task) {
    String selectedStatus = task.status;
    final statuses = [
      'Not Started',
      'In Progress',
      'Needs Review',
      'Completed'
    ];

    showModalBottomSheet(
      context: screenContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheet) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (dragContext, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Text(
                        'Chọn trạng thái task',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Map status list -> StatusTaskCard widgets
                      ...statuses.map((status) => StatusTaskCard(
                            status: status,
                            isCurrent: selectedStatus == status,
                            onChanged: (_) {
                              setState(() {
                                selectedStatus = status;
                              });
                            },
                          )),

                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () {
                                Navigator.pop(
                                    screenContext); // Close bottom sheet
                              },
                              child: Text('Hủy',
                                  style:
                                      GoogleFonts.aBeeZee(color: Colors.white)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 58, 13, 220)),
                              onPressed: () {
                                final taskBloc = screenContext.read<TaskBloc>();
                                if (!taskBloc.isClosed) {
                                  taskBloc.add(UpdateTask(
                                    taskId: task.id,
                                    projectId: widget.projectId,
                                    updateField: {'status': selectedStatus},
                                  ));

                                  Navigator.pop(screenContext);
                                } else {
                                  print('DISPOSE');
                                }
                              },
                              child: Text('OK',
                                  style:
                                      GoogleFonts.aBeeZee(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: MultiBlocListener(
          listeners: [
            BlocListener<TaskBloc, TaskState>(
              listener: (context, state) {
                print('Current State TaskBloc: $state');
                if (state is TaskUpdatedSuccess) {
                  // Sau khi update thành công, refresh lại data
                  _refreshData();
                } else if (state is TaskCreatedSuccess) {
                  // Sau khi tạo task thành công, refresh lại data
                  _refreshData();
                } else if (state is TaskDeleteSuccess) {
                  // Sau khi xóa task thành công, refresh lại data
                  _refreshData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Xóa task thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is TaskError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _mapErrorToMessage(state.error),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 3),
                    ),
                  );

                  context.read<TaskBloc>().add(GetCacheTasks());
                }
              },
            ),
            BlocListener<ProjectBloc, ProjectState>(listener: (context, state) {
              if (state is ProjectFetchSuccess) {
                final updatedProject = state.project;
                final homeState = context.read<HomeBloc>().state;

                print('State Home: $homeState');

                if (homeState is HomeLoadSuccess) {
                  final updatedProjects = homeState.projects!.map((project) {
                    return project.id == updatedProject.id
                        ? updatedProject
                        : project;
                  }).toList();

                  context.read<HomeBloc>().add(UpdateProjects(updatedProjects));
                }
              }
            })
          ],
          child: Scaffold(
            backgroundColor: Colors.grey.shade100,
            body: RefreshIndicator(
              onRefresh: () async {
                _refreshData();
                // Đợi một chút để đảm bảo data được load
                await Future.delayed(Duration(milliseconds: 500));
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 55,
                    automaticallyImplyLeading: false,
                    flexibleSpace: CustomAppBar(
                      title: 'Project Detail',
                      isReload: true,
                      actions: [
                        BlocBuilder<ProjectBloc, ProjectState>(
                            builder: (context, state) {
                          if (state is ProjectFetchSuccess) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                state.project.status,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                            );
                          }
                          return Text('');
                        }),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: BlocBuilder<ProjectBloc, ProjectState>(
                      builder: (context, state) {
                        print("Current ProjectState: $state"); // debug
                        if (state is ProjectLoading ||
                            state is ProjectInitial) {
                          return Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ShimmerWidget.rectangular(
                              height: MediaQuery.of(context).size.height * 0.5,
                            ),
                          ));
                        } else if (state is ProjectFetchSuccess) {
                          print('Fetch Project Thành công');
                          final project = state.project;
                          if (project == null) {
                            return const Center(
                                child: Text('Không tìm thấy dữ liệu dự án'));
                          }
                          return ProjectDetailedCard(project: project);
                        } else if (state is ProjectError) {
                          return Center(
                              child: Text(_mapErrorToMessage(state.error)));
                        }
                        return const Center(
                            child: Text('Chưa có dữ liệu dự án'));
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          children: [
                            _buildProgressProject(),
                            const SizedBox(
                              height: 40,
                            )
                          ],
                        )),
                  ),
                  _buildListActivity(context),
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildListActivity(BuildContext contextScreen) {
    return BlocConsumer<TaskBloc, TaskState>(listener: (context, state) {
      if (state is TaskLoadSuccess) {
        state.message != null
            ? SuccessHelper.showSuccess(context, state.message, Colors.green)
            : null;
      }
    }, builder: (context, state) {
      final authState = context.read<AuthBloc>().state;
      String currentUserId = '';
      if (authState is GetLocalUserSuccess) {
        currentUserId = authState.user.userId;
      }

      // LOADING state => shimmer
      if (state is TaskLoading) {
        return SliverList(
          delegate: SliverChildListDelegate([
            _buildLabelSection(label: 'Assigned To You'),
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(
                  4,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ShimmerWidget.rectangular(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.9,
                    ),
                  ),
                ),
              ),
            ),
            _buildLabelSection(label: 'List Activities'),
            ...List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.all(5),
                child: ShimmerWidget.rectangular(
                  height: MediaQuery.of(context).size.width * 0.45,
                ),
              ),
            ),
          ]),
        );
      }

      // LOAD SUCCESS
      if (state is TaskLoadSuccess) {
        if (state.tasks.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyTaskView());
        }

        final assignedTasks = state.tasks
            .where((task) =>
                task.assignees.any((user) => user.userId == currentUserId))
            .toList();

        return SliverList(
          delegate: SliverChildListDelegate([
            _buildLabelSection(label: 'Assigned To You'),
            assignedTasks.isEmpty
                ? _buildEmptyTaskView()
                : SizedBox(
                    height: 240,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: assignedTasks.map((task) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: TaskInProjectCard(
                            onEdit: () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return EditTaskScreen(taskId: task.id);
                            })),
                            task: task,
                            isHorizontal: true,
                            onMarks: () =>
                                showStatusDialog(contextScreen, task),
                            onDelete: () => deleteTask(task.id, context),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
            _buildLabelSection(
                label: 'List Activities', label2: 'View All', onTap: onViewAll),
            ElevatedButton(
              onPressed: () async {
                // Sử dụng await để đợi kết quả từ màn hình tạo task
                final result = await context.pushNamed(
                  'createNewTaskScreen',
                  extra: widget.projectId,
                );

               
                if (result == true) {
                  _refreshData();
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ).merge(
                ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  elevation: MaterialStateProperty.all<double>(0),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A5AE0), Color(0xFF8D8AD1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  child: Text(
                    '➕ Thêm Nhiệm Vụ Mới',
                    style: GoogleFonts.robotoFlex(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            ...List.generate(state.tasks.length, (index) {
              final item = state.tasks[index];
              final isLast = index == state.tasks.length - 1;

              return Column(
                children: [
                  TaskInProjectCard(
                    onEdit: () async {
                    final result = await  Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return EditTaskScreen(taskId: item.id);
                    })); 
                    if (result == true) {
                       _refreshData();
                    }
                    } ,
                    task: item,
                    onDelete: () => deleteTask(item.id, context),
                    onMarks: () => showStatusDialog(contextScreen, item),
                  ),
                  if (isLast) const SizedBox(height: 200),
                ],
              );
            }),
          ]),
        );
      }

      return const SliverToBoxAdapter(child: SizedBox());
    });
  }

  void onViewAll() async {
    // Đợi kết quả từ màn hình view all tasks
    final result =
        await context.pushNamed('viewListTaskScreen', extra: widget.projectId);

    // Nếu có thay đổi, refresh data
    if (result == true) {
      _refreshData();
    }
  }

  Widget _buildLabelSection(
      {required String label, VoidCallback? onTap, String? label2}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.robotoFlex(
              color: const Color.fromARGB(255, 7, 41, 92),
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap != null && label2 != null
              ? TextButton(
                  onPressed: onTap,
                  child: Text(
                    label2,
                    style: GoogleFonts.afacad(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget _buildEmptyTaskView() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Chưa có nhiệm vụ nào được tạo 📝',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hãy bắt đầu bằng cách thêm một task mới!',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  String _mapErrorToMessage(String error) {
    if (error.contains('DioError') || error.contains('Connection')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else if (error.contains('Unauthorized')) {
      return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
    } else if (error.contains('permission')) {
      return 'Bạn không có quyền đối với tài nguyên này';
    }
    return 'Đã xảy ra lỗi: $error';
  }

  Widget _buildProgressProject() {
    return BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
      if (state is TaskLoading) {
        return Center(
            child: ShimmerWidget.rectangular(
          height: MediaQuery.of(context).size.height * 0.5,
        ));
      } else if (state is TaskLoadSuccess) {
        final int completedTask = state.tasks
            .where((item) => item.status == 'Completed')
            .toList()
            .length;
        final double percent =
            state.tasks.isEmpty ? 0.0 : completedTask / state.tasks.length;
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth * 0.45; // 35% chiều rộng màn hình
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Text(
                        'Project Progress',
                        style: GoogleFonts.robotoFlex(
                          color: const Color.fromARGB(255, 7, 41, 92),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 67, 95, 234),
                                shape: BoxShape.circle),
                            child: Text(
                              '$completedTask',
                              style:
                                  GoogleFonts.robotoFlex(color: Colors.white),
                            ),
                          ),
                          Text('/'),
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 67, 95, 234),
                                shape: BoxShape.circle),
                            child: Text(
                              '${state.tasks.length}',
                              style:
                                  GoogleFonts.robotoFlex(color: Colors.white),
                            ),
                          ),
                          Text(
                            'Tasks',
                            style: GoogleFonts.robotoFlex(
                                color: const Color.fromARGB(255, 20, 14, 14),
                                fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: percent),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Container(
                      padding: const EdgeInsets.all(15),
                      height: size,
                      width: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          startAngle: 0.0,
                          endAngle: 3.14 * 2,
                          stops: [value, value],
                          colors: [
                            _getProgressColor(value),
                            Colors.grey.shade200,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getProgressColor(value).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            '${(value * 100).toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: size * 0.2,
                              fontWeight: FontWeight.bold,
                              color: _getProgressColor(value),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            );
          },
        );
      }
      return const Text('No tasks available',
          style: TextStyle(color: Colors.grey));
    });
  }

// Màu sắc động dựa trên tiến độ
  Color _getProgressColor(double percent) {
    if (percent < 0.3) {
      return Colors.red.shade400;
    } else if (percent < 0.7) {
      return const Color.fromARGB(255, 74, 38, 255);
    } else {
      return Colors.green.shade400;
    }
  }
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Color getColorTypeMessage(String type) {
  final lowerType = type.toLowerCase();

  if (lowerType.contains('xóa')) {
    return Colors.red;
  } else if (lowerType.contains('tạo')) {
    return Colors.green;
  } else if (lowerType.contains('cập nhật')) {
    return Colors.orange;
  }

  return Colors.grey; // default
}
