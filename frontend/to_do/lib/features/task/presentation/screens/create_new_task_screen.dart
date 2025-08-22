import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/utils/helpers/success.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/home/presentation/bloc/home_bloc.dart';
import 'package:to_do/features/home/presentation/bloc/home_event.dart';
import 'package:to_do/features/home/presentation/bloc/home_state.dart';
import 'package:to_do/features/projects/domain/entities/project_member_entity.dart';
import 'package:to_do/features/projects/presentation/bloc/member_project_cubit.dart';
import 'package:to_do/features/projects/presentation/bloc/project_bloc.dart';
import 'package:to_do/features/projects/presentation/bloc/project_event.dart';
import 'package:to_do/features/projects/presentation/bloc/project_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do/features/stats/presentation/blocs/stats_bloc.dart';
import 'package:to_do/features/stats/presentation/blocs/stats_event.dart';
import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:to_do/features/task/presentation/bloc/task_event.dart';
import 'package:to_do/features/task/presentation/bloc/task_state.dart';
import 'package:to_do/features/users/presentation/widgets/custom_member_card2.dart';
import 'package:to_do/injection.dart';

class CreateNewTaskScreen extends StatefulWidget {
  //final List<ProjectMemberEntity> members;
  final String project_id;
  const CreateNewTaskScreen({super.key, required this.project_id});

  @override
  State<CreateNewTaskScreen> createState() => _CreateNewTaskScreenState();
}

class _CreateNewTaskScreenState extends State<CreateNewTaskScreen> {
  // Variable
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  FocusNode _titleFC = FocusNode();
  FocusNode _descriptionFC = FocusNode();

  DateTime? selectedDatetime;

  Set<String> assignedUserId = {};

  List<ProjectMemberEntity> selectedUser = [];

  String selectedPriority = 'Low';

  @override
  void dispose() {
    _titleFC.dispose();
    _descriptionFC.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MemberProjectCubit>().fetchMembers(widget.project_id);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBloc>();
      // Do something with bloc
    });
  }

  void selectDateTime(DateTime? date) {
    setState(() {
      selectedDatetime = date;
    });
     // Clear focus để không bật bàn phím
    FocusScope.of(context).unfocus();

  }

  void onAdd() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocBuilder<MemberProjectCubit, List<ProjectMemberEntity>>(
          builder: (context, members) {
            if (members.isEmpty) {
              return AlertDialog(
                content: Text("Chưa có dữ liệu thành viên"),
              );
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Thành viên dự án',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter dialogSetState) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.maxFinite,
                    child: ListView(
                      children: [
                        for (var member in members)
                          CustomMemberCard2(
                            member,
                            onAssgin: () {
                              setState(() {
                                if (assignedUserId.contains(member.id)) {
                                  assignedUserId.remove(member.id);
                                } else {
                                  assignedUserId.add(member.id);
                                }
                              });
                              dialogSetState(() {});
                            },
                            isAssigned: assignedUserId.contains(member.id),
                          ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Đóng'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedUser = members
                          .where((item) => assignedUserId.contains(item.id))
                          .toList();
                    });

                    print(selectedUser[0].name);

                    context.pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void onRemoveAssign(String selectedRemoveUser) {
    setState(() {
      selectedUser.removeWhere((u) => u.id == selectedRemoveUser);
      assignedUserId.remove(selectedRemoveUser);
    });
  }

  void selectPriority(String value) {
    setState(() {
      selectedPriority = value;
    });
  }

  // Create Task
  void createTask() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        selectedDatetime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')));
    } else {
      String title = _titleController.text.trim(); 
      String description = _descriptionController.text.trim(); 
      var dueDate = selectedDatetime;
      String priority = selectedPriority;

      List<String> assignees = assignedUserId.toList();
      print(assignees);
      print(selectedPriority);

      final fieldTask = {
        'title': title,
        "description": description,
        "priority": selectedPriority,
        "dueDate": selectedDatetime!.toIso8601String(),
        "projectId": widget.project_id,
        "assigneeIds": assignees
      };

      // Status Default: Not Started
      context.read<TaskBloc>().add(CreateTask(fieldTask));

      // Cập nhật lại lại Danh Sách Projects

      // Get lại project đã update
      // Cập nhật vào List Project
    }
  }

  void clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      selectedPriority = 'Low';
      selectedUser.clear();
      assignedUserId.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<TaskBloc, TaskState>(listener: (context, state) {
            if (state is TaskError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Created Task Failure: ${state.error}')),
              );
            } else if (state is TaskCreatedSuccess) {
              clearForm();
              
              SuccessHelper.showSuccess(context, 'Tạo một nhiệm vụ mới thành công', Colors.green);
              context.read<StatsBloc>().add(LoadStatsUser());
              context.read<HomeBloc>().add(UpdateListHomeTask(state.task)); 

             

              



              //context.read<HomeBloc>().add()
              // Nếu tạo task thành công => Gọi lại Project mới đó để cập nhận vào danh sách hiện tại ở Home

              // Không fetch lại toàn bộ danh sách => mà lấy danh sách hiện tại

              // TODO 1: Update List Project

              context
                  .read<ProjectBloc>()
                  .add(FetchProjectById(widget.project_id));
            }
          }),
          BlocListener<ProjectBloc, ProjectState>(
            listener: (context, state) {
              if (state is ProjectFetchSuccess) {
                //context.read<ProjectBloc>().add(FetchMemberByProject(widget.project_id));
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
            },
          ),
        ],
        child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 254, 249, 249),
            body: Stack(children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    actions: [
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.more_vert_outlined,
                            size: 30,
                          ),
                        ),
                      )
                    ],
                    centerTitle: true,
                    leading: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle),
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    backgroundColor: const Color.fromARGB(255, 254, 249, 249),
                    title: Text(
                      'Create New Task',
                      style: GoogleFonts.robotoFlex(
                          fontWeight: FontWeight.w700, fontSize: 25),
                    ),
                  ),
                  SliverToBoxAdapter(
                      child: _buildFormField(
                          hintText: 'Task Tilte',
                          controller: _titleController,
                          nextFocus: _descriptionFC,
                          currentFC: _titleFC)),
                  SliverToBoxAdapter(
                      child: _buildFormField(
                          hintText: 'Add a description',
                          controller: _descriptionController,
                          currentFC: _descriptionFC,
                          maxLine: 5, 
                          inputAction: TextInputAction.newline
                          )),
                  SliverToBoxAdapter(
                      child: _buildDueTime(
                          (selectedTime) => selectDateTime(selectedTime))),
                  SliverToBoxAdapter(
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 1), // Dịch bóng theo trục x, y
                            ),
                          ]),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_calendar,
                            color: Colors.blueAccent.shade700,
                            size: 30,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            selectedDatetime != null
                                ? '${Utils.formatDate2(selectedDatetime)}, ${Utils.getTime(selectedDatetime)}'
                                : '${Utils.formatDate2(DateTime.now())}, ${Utils.getTime(DateTime.now())}',
                            style: GoogleFonts.robotoFlex(
                                fontSize: 20, color: Colors.grey.shade400),
                          )
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildParticipantSection(onAdd: onAdd),
                  ),
                  SliverToBoxAdapter(
                      child: _buildPriority(
                          selectedPriority: selectedPriority,
                          onChanged: (value) => selectPriority(value!))),

                  // Button Create Task
                  SliverToBoxAdapter(
                      child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.blue.shade100),
                        onPressed: () {
                          createTask();
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: BlocBuilder<TaskBloc, TaskState>(
                                builder: (context, state) {
                              if (state is TaskLoading) {
                                return CircularProgressIndicator();
                              } else if (state is TaskCreatedSuccess) {
                                return Text(
                                  'Create Task',
                                  style: GoogleFonts.robotoFlex(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 25,
                                    color:
                                        const Color.fromARGB(255, 50, 48, 48),
                                  ),
                                );
                              } else if (state is TaskError) {}
                              return Text(
                                'Create Task',
                                style: GoogleFonts.robotoFlex(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 25,
                                  color: const Color.fromARGB(255, 50, 48, 48),
                                ),
                              );
                            }))),
                  )),
                ],
              ),
            ])));
  }

  // User Card

  // -- Part 4: _build Priority -- Gửi dữ liệu từ con ra cha
  Widget _buildPriority(
      {required String selectedPriority, void Function(String?)? onChanged}) {
    List<String> priorities = ['Low', 'Medium', 'High', 'Urgent'];

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Priority',
                style: GoogleFonts.robotoFlex(
                    fontWeight: FontWeight.w700, fontSize: 25),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                  value: selectedPriority,
                  items: priorities.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.robotoFlex(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  dropdownColor: Colors.white,
                  style: GoogleFonts.robotoFlex(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDueTime(
      BuildContext context, void Function(DateTime? time) onSelectTime) async {
    final DateTime? pickDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2004),
      lastDate: DateTime(2080),
      initialDate: DateTime.now(),
    );

    if (pickDate != null) {
      final TimeOfDay? pickTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickTime != null) {
        // Gộp ngày và giờ lại thành 1 DateTime
        final DateTime finalDateTime = DateTime(
          pickDate.year,
          pickDate.month,
          pickDate.day,
          pickTime.hour,
          pickTime.minute,
        );

        onSelectTime(finalDateTime); // Gửi DateTime đã có cả ngày + giờ
      } else {
        // Nếu người dùng không chọn giờ, vẫn gọi callback với ngày
        onSelectTime(pickDate);
      }
    }
  }

  Widget _buildDueTime(void Function(DateTime? time) onSelectTime) {
    return Padding(
      padding: const EdgeInsets.only(right: 160, left: 10, top: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 23, 70, 198),
            side: BorderSide(width: 1, color: Colors.grey)),
        onPressed: () {
          _pickDueTime(context, onSelectTime);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Text(
            'Choose Due Date',
            style: GoogleFonts.robotoFlex(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
      {required String hintText,
      TextEditingController? controller,
      FocusNode? currentFC,
      FocusNode? nextFocus,
       TextInputAction inputAction = TextInputAction.next,
      int maxLine = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextFormField(
        maxLines: maxLine,
        textInputAction: inputAction,
        //keyboardType: keyboardType,
        controller: controller,
        focusNode: currentFC,
        style: GoogleFonts.robotoFlex(),
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(nextFocus);
        },
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            label: Text(hintText),
            labelStyle: GoogleFonts.robotoFlex(),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1))),
      ),
    );
  }

  Widget _buildParticipantSection({VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participants',
            style: GoogleFonts.robotoFlex(
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 50,
              child: InkWell(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 23, 70, 198),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: selectedUser != null
                    ? SizedBox(
                        height:
                            60, // Chiều cao của list item (có thể điều chỉnh)
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedUser.length,
                          itemBuilder: (context, index) {
                            final member = selectedUser[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _buildSelectedUser(
                                user: member,
                                onRemoveAssign: (id) {
                                  onRemoveAssign(id);
                                },
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        'No participants selected',
                        style: GoogleFonts.robotoFlex(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      )),
          ]),
        ],
      ),
    );
  }

  Widget _buildSelectedUser(
      {required ProjectMemberEntity user,
      void Function(String)? onRemoveAssign}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.avatar),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(user.name, style: GoogleFonts.robotoFlex(fontSize: 15)),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
              onTap: () {
                if (onRemoveAssign != null) {
                  onRemoveAssign(user.id);
                }
              },
              child: Icon(Icons.close))
        ],
      ),
    );
  }
}
