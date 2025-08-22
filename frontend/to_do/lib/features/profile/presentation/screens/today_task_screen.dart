import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/app_router.dart';
import 'package:to_do/core/common/custom_back_button.dart';
import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/task/presentation/bloc/task_event.dart';
import 'package:to_do/features/task/presentation/bloc/task_state.dart';
import 'package:to_do/features/task/presentation/widgets/card_square_task.dart';
import 'package:to_do/features/task/presentation/widgets/empty_task_widget.dart';
import 'package:to_do/features/task/presentation/widgets/task_in_project_card.dart';

class TodayTaskScreen extends StatefulWidget {
  const TodayTaskScreen({super.key});

  @override
  State<TodayTaskScreen> createState() => _TodayTaskScreenState();
}

class _TodayTaskScreenState extends State<TodayTaskScreen> with RouteAware {
  late TaskBloc _taskBloc;
  bool isListView = true;
  @override
  void initState() {
    super.initState();
    _taskBloc = context.read<TaskBloc>();
    _taskBloc.add(FetchTaskToday());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đăng ký với routeObserver để lắng nghe khi màn hình này được focus lại
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Gọi khi quay lại từ màn hình khác
    _taskBloc.add(FetchTaskToday());
  }

  void showMore() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, top: 35, bottom: 10),
              child: Row(
                children: [
                  CustomBackButton(
                    onPress: () {
                      context.pop();
                    },
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  // Label
                  Text('Nhiệm Vụ Hôm Nay',
                      style: GoogleFonts.afacad(
                          fontWeight: FontWeight.w800, fontSize: 28)),
                  Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'toggleView':
                          setState(() => isListView = !isListView);
                          print('isListView: , ${isListView}');
                          break;
                        case 'home':
                          context.go('/home');
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggleView',
                        child: Row(
                          children: [
                            Icon(isListView ? Icons.grid_view : Icons.list,
                                size: 18),
                            SizedBox(width: 12),
                            Text(isListView ? 'Grid View' : 'List View'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'home',
                        child: Row(
                          children: [
                            Icon(Icons.home_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Home'),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
            print('task today state: $state');
            if (state is TaskLoading) {
              return SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state is TaskTodayFetchSuccess) {
              if (state.todayTasks.isEmpty) {

                return SliverToBoxAdapter(
                  child: EmptyTaskWidget()
                ); 
              }

              if (isListView) {
                //  List View
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = state.todayTasks[index];
                      return TaskInProjectCard(task: item,);
                    },
                    childCount: state.todayTasks.length,
                  ),
                );
              } else {
                // Grid View
                return SliverPadding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = state.todayTasks[index];
                        return CardSquareTask(task: item,);
                      },
                      childCount: state.todayTasks.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1, // adjust height/width
                    ),
                  ),
                );
              }
            }
            return SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          })
        ],
      ),
    );
  }
}
