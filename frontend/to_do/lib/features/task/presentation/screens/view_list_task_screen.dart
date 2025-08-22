import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';
import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:to_do/features/task/presentation/bloc/task_event.dart';
import 'package:to_do/features/task/presentation/bloc/task_state.dart';
import 'package:to_do/features/task/presentation/widgets/task_in_project_card.dart';
import '../../../../injection.dart';

class ViewListTaskScreen extends StatefulWidget {
  final String projectId;
  const ViewListTaskScreen({super.key, required this.projectId});

  @override
  State<ViewListTaskScreen> createState() => _ViewListTaskScreenState();
}

class _ViewListTaskScreenState extends State<ViewListTaskScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<TaskEntity> _tasks = [];

  // Filter tasks by day (year, month, day comparison)
  List<TaskEntity> getTasksForDay(DateTime day) {
    return _tasks.where((task) {
      final d = task.dueDate;
      return d != null &&
          d.year == day.year &&
          d.month == day.month &&
          d.day == day.day;
    }).toList();
  }

  // Find tasks closest to the current time
  List<TaskEntity> getTaskNearCurrent() {
    final now = DateTime.now();
    final validTasks = _tasks.where((t) => t.dueDate != null && !Utils.isOverdue(t.dueDate!) 
    && t.status != 'Completed'
    ).toList();
    if (validTasks.isEmpty) return [];

    final taskDiffs = validTasks.map((t) {
      final diff = t.dueDate!.difference(now).inSeconds.abs();
      return {'task': t, 'diff': diff};
    }).toList();

    final minDiff =
        taskDiffs.map((e) => e['diff'] as int).reduce((a, b) => a < b ? a : b);
    return taskDiffs
        .where((e) => e['diff'] == minDiff)
        .map((e) => e['task'] as TaskEntity)
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<TaskBloc>().add(LoadTaskForAProject(widget.projectId));
  }

  Widget _buildMessageStatus(String label) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25))),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Center(
          child: Text(label,
              style: GoogleFonts.afacad(
                  fontSize: 30, fontWeight: FontWeight.w800))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskLoadSuccess) {
              _tasks = state.tasks; 
              final eventsForSelectedDay =
                  getTasksForDay(_selectedDay ?? _focusedDay);
              final taskNearCurrents = getTaskNearCurrent();

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.only(top: 40, left: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 3,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blueAccent.shade700,
                                  shape: BoxShape.rectangle),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: DateTime(2000, 1, 1),
                      lastDay: DateTime(2100, 12, 31),
                      pageJumpingEnabled: true,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, _selectedDay),
                      eventLoader: (day) => getTasksForDay(day),
                      calendarStyle: const CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Color.fromARGB(255, 216, 31, 40),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 1,
                        weekendTextStyle: TextStyle(color: Colors.red),
                        outsideDaysVisible: false,
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: false,
                        titleTextStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon:
                            Icon(Icons.chevron_left, color: Colors.blue),
                        rightChevronIcon:
                            Icon(Icons.chevron_right, color: Colors.blue),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onHeaderTapped: (focusedDay) async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _focusedDay,
                          firstDate: DateTime(2000, 1, 1),
                          lastDate: DateTime(2100, 12, 31),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _focusedDay = pickedDate;
                            _selectedDay = pickedDate;
                          });
                        } else {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No date selected')),
                          );

                        }
                      },
                    ),
                  ),
                  if (_tasks.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(child: Text('No tasks available')),
                    )
                  else if (eventsForSelectedDay.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                          child: _buildMessageStatus('No Tasks for this Day')),
                    )
                  else
                    SliverToBoxAdapter(
                        child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text('Tasks',
                          style: GoogleFonts.afacad(
                              fontSize: 30, fontWeight: FontWeight.w800)),
                    )),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: eventsForSelectedDay.length,
                      (context, index) {
                        final task = eventsForSelectedDay[index];
                        return Column(
                          children: [
                            TaskInProjectCard(
                              task: task,
                              isCurrent: taskNearCurrents.contains(task),
                            ),
                            if (index == eventsForSelectedDay.length - 1)
                              const SizedBox(
                                height: 50,
                              )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is TaskError) {
              return Center(child: Text('Error: ${state.error}'));
            }
            return const SizedBox.shrink();
          },
        ));
  }
}
