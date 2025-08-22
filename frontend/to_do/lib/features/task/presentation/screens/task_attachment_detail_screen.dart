import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_bloc.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_event.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_state.dart';
import 'package:to_do/features/attachments/presentation/bloc/widgets/card_attachment.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:to_do/features/task/presentation/bloc/task_event.dart';
import 'package:to_do/features/users/presentation/widgets/user_card.dart';

class TaskAttachmentDetailScreen extends StatefulWidget {
  final String taskId;
  final List<UserEntity> assignees;
  final String taskTitle;
  final String projectId; 

  const TaskAttachmentDetailScreen({
    super.key,
    required this.taskId,
    required this.assignees,
    required this.taskTitle,
    required this.projectId 
  });

  @override
  State<TaskAttachmentDetailScreen> createState() =>
      _TaskAttachmentDetailScreenState();
}

class _TaskAttachmentDetailScreenState
    extends State<TaskAttachmentDetailScreen> {
  bool isExpandedFiles = false;
  bool isExpandedMembers = false;

  @override
  void initState() {
    super.initState();
    context.read<AttachmentBloc>().add(FetchTaskFiles(taskId: widget.taskId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),

          // Task Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.taskTitle,
                style: GoogleFonts.robotoFlex(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          _buildExpandableSection(
            title: "File đính kèm",
            icon: Icons.attach_file,
            isExpanded: isExpandedFiles,
            onTap: () => setState(() => isExpandedFiles = !isExpandedFiles),
            child: _buildListFile(),
          /*   action: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () {
                // TODO: Thêm logic upload file
              },
            ), */
          ),

          _buildExpandableSection(
            title: "Thành viên được phân công",
            icon: Icons.people_alt_outlined,
            isExpanded: isExpandedMembers,
            onTap: () => setState(() => isExpandedMembers = !isExpandedMembers),
            child: _buildMemberList(),
  
          ),


          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0, 
                backgroundColor: const Color.fromARGB(255, 12, 27, 52), 
            
              ),
              onPressed: () {
                   context.read<TaskBloc>().add(TaskReset());
                  context.read<TaskBloc>().add(LoadTaskForAProject(widget.projectId));
                  context.pushNamed('projectDetail', extra: widget.projectId);

            }, child: Text('Xem thông tin project liên quan', style: GoogleFonts.inika(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),)),
          ),)
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 60,
      leading: InkWell(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      title: Text(
        'Tùy Chọn',
        style: GoogleFonts.robotoFlex(color: Colors.white, fontSize: 18),
      ),
      backgroundColor: const Color(0xFF319AF0),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
    Widget? action,
  }) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: Colors.white,
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.grey[700]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (action != null) action,
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.arrow_drop_down_outlined, size: 30),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: child,
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListFile() {
    return BlocBuilder<AttachmentBloc, AttachmentState>(
      builder: (context, state) {
        if (state is AttachmentLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        if (state is AttachmentFetchSuccess) {
          if (state.files.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Không có file nào'),
            );
          }

          return Column(
            children: state.files
                .map((item) => CardAttachment(item))
                .toList(),
          );
        }

        return const Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildMemberList() {
    if (widget.assignees.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Không có thành viên'),
      );
    }

    return Column(
      children: widget.assignees
          .map((item) => UserCard(item, isHidden: true))
          .toList(),
    );
  }
}
