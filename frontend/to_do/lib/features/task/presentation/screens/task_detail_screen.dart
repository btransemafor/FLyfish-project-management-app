import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/core/app_router.dart';
import 'package:to_do/core/utils/helpers/success.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_bloc.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_event.dart';
import 'package:to_do/features/attachments/presentation/bloc/attachment_state.dart';
import 'package:to_do/features/attachments/presentation/bloc/widgets/card_attachment.dart';
import 'package:to_do/features/auth/domain/entities/user_entity.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:to_do/features/comments/domain/entity/comment_entity.dart';
import 'package:to_do/features/comments/presentation/Bloc/comment_bloc.dart';
import 'package:to_do/features/comments/presentation/Bloc/comment_event.dart';
import 'package:to_do/features/comments/presentation/Bloc/comment_state.dart';
import 'package:to_do/features/comments/presentation/widget/comment_card.dart';
import 'package:to_do/features/task/presentation/bloc/task_bloc.dart';
import 'package:to_do/features/task/presentation/bloc/task_event.dart';
import 'package:to_do/features/task/presentation/bloc/task_state.dart';
import 'package:to_do/features/task/presentation/screens/edit_task_screen.dart';
import 'package:to_do/features/task/presentation/widgets/card_task_detail.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> with RouteAware {
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TaskBloc taskBloc;
  late CommentBloc commentBloc;

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(FetchCommentsEvent(widget.taskId));
    context.read<AttachmentBloc>().add(FetchTaskFiles(taskId: widget.taskId));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);

    // Cache blocs here, safe because dependencies are available
    taskBloc = context.read<TaskBloc>();
    commentBloc = context.read<CommentBloc>();
  }

  @override
  void dispose() {
    commentBloc.add(StopListeningToComments()); // ✅ now safe
    _commentController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Gọi khi quay lại từ màn hình khác
    _handleRefresh();
  }

  Future<void> _handleRefresh() async {
    context.read<TaskBloc>().add(FetchTaskDetail(widget.taskId));
  }

  final _targetKey = GlobalKey();
  final FocusNode _commentFocusNode = FocusNode();
  String? _replyToParentId; // lưu parentId nếu đang reply

  void onEdit() async {
    // For Edit Task
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditTaskScreen(taskId: widget.taskId)));
    if (result == true) {
      _handleRefresh();
    }
  }

  void onRemoveUser(BuildContext context, UserEntity user) {
    context
        .read<TaskBloc>()
        .add(RemoveUserFromTaskEvent(widget.taskId, user.userId));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TaskBloc, TaskState>(
          listener: (context, state) {
            print('[TaskBloc Listener] State: ${state.runtimeType}');

            if (state is UserOfTaskRemovedSuccess) {
              print('[TaskBloc Listener] ✅ UserOfTaskRemovedSuccess');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã xóa người dùng khỏi task thành công',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.all(16),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        // Có thể thêm listener cho AttachmentBloc hoặc CommentBloc nếu cần
        BlocListener<AttachmentBloc, AttachmentState>(
          listener: (context, state) {
            if (state is FileUploadedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tải File lên Thành Công'),
                  backgroundColor: Colors.green[600],
                ),
              );
            }
          },
        ),
      ],
      child: RefreshIndicator(
        key: _scaffoldKey,
        onRefresh: _handleRefresh,
        color: Colors.white,
        backgroundColor: Colors.blue.shade900,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildHeader(),
                _buildTaskDetail(),
                const SizedBox(height: 10),
                _buildFileSection(),
                const SizedBox(height: 20),
                _buildCommentSection(),
                const SizedBox(height: 12),
                _buildCommentInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tệp mô tả chính',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          BlocConsumer<AttachmentBloc, AttachmentState>(
            listener: (context, state) {
              if (state is FileUploadedSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tải File lên Thành Công',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating, // nổi lên,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.all(16),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            builder: (context, state) {
              print('Attachment STATE: $state');
              if (state is AttachmentFetchSuccess) {
                final mainFiles =
                    state.files.where((item) => item.is_main == true).toList();
                if (mainFiles.isEmpty) {
                  return _buildEmptyStateFile();
                }
                return Column(
                  children: mainFiles.map((file) {
                    return CardAttachment(file);
                  }).toList(),
                );
              }

              if (state is AttachmentLoading) {
                return const CircularProgressIndicator();
              }

              return const Text('No File');
            },
          ),
          Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildUploadButton(() => uploadFile(context)),
              ))
        ],
      ),
    );
  }

  Widget _buildEmptyStateFile() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.file_upload_outlined,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có file nào',
              style: GoogleFonts.robotoFlex(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Hàm hiển thị dialog chọn có phải là file chính
  Future<bool> _showOptionMainFile(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            elevation: 24,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon với animation
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 24),

                    // Title
                    Text(
                      'Chọn file chính',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 12),

                    // Content
                    Text(
                      'Bạn có muốn đánh dấu tệp này là file chính không?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 32),

                    // Buttons
                    Row(
                      children: [
                        // Nút Không
                        Expanded(
                          child: Container(
                            height: 56,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.shade100,
                                foregroundColor: Colors.grey.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Không',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        // Nút Có
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade500,
                                  Colors.purple.shade500
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 0,
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
                                elevation: 0,
                              ),
                              child: Text(
                                'Có',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false; // nếu người dùng bấm ra ngoài hoặc back, trả về false
  }

// Ham upload File:
  void uploadFile(BuildContext context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    //final bool main = true;
    bool is_main = await _showOptionMainFile(context);

    if (result != null) {
      context.read<AttachmentBloc>().add(
          UploadFile(taskId: widget.taskId, result: result, is_main: is_main));
    } else {
      //
    }
  }

  Widget buildUploadButton(VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(
        Icons.upload_file,
        size: 20,
        color: Colors.white,
      ),
      label: const Text(
        'Upload File',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Chi tiết công việc',
          style:
              GoogleFonts.robotoFlex(fontSize: 25, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        InkWell(
          onTap: () async {
            // Dispatch fetch task detail
            context.read<TaskBloc>().add(FetchTaskDetail(widget.taskId));

            // Lắng nghe state mới 1 lần để push
            final state = await context.read<TaskBloc>().stream.firstWhere(
                  (state) => state is TaskDetailFetchedSuccess,
                );

            if (state is TaskDetailFetchedSuccess) {
              context.pushNamed(
                'taskAttachmentDetailScreen',
                extra: {
                  'taskId': widget.taskId,
                  'title': state.task?.title ?? '',
                  'projectId': state.task!.projectId,
                  'users': state.task?.assignees ?? [],
                },
              );
            }
          },
          child: const Icon(Icons.more_vert, size: 30),
        ),
      ],
    );
  }

/*   Widget _buildTaskDetail() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskDetailFetchedSuccess) {
          return CardTaskDetail(
            onRemoveUser: (BuildContext context, UserEntity user) async {
              // Dispatch sự kiện xóa user đến TaskBloc
              context
                  .read<TaskBloc>()
                  .add(RemoveUserFromTaskEvent(widget.taskId, user.userId));
            },
            state.task!,
            showActions: true,
            onEdit: onEdit,
          );
        }

        // Thêm case này để handle UserOfTaskRemovedSuccess
        if (state is UserOfTaskRemovedSuccess) {
          return CardTaskDetail(
            onRemoveUser: (BuildContext context, UserEntity user) async {
              context
                  .read<TaskBloc>()
                  .add(RemoveUserFromTaskEvent(widget.taskId, user.userId));
            },
            state.updatedTask, // Sử dụng task đã được cập nhật
            showActions: true,
            onEdit: onEdit,
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  } */

  Widget _buildTaskDetail() {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        print('[BlocConsumer Listener] State: ${state.runtimeType}');

        if (state is UserOfTaskRemovedSuccess) {
          print('[BlocConsumer] ✅ UserOfTaskRemovedSuccess in listener');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa người dùng thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        print('[BlocConsumer Builder] State: ${state.runtimeType}');

        if (state is TaskDetailFetchedSuccess) {
          return CardTaskDetail(
            onRemoveUser: (BuildContext context, UserEntity user) async {
              context
                  .read<TaskBloc>()
                  .add(RemoveUserFromTaskEvent(widget.taskId, user.userId));
            },
            state.task!,
            showActions: true,
            onEdit: onEdit,
          );
        }

        if (state is UserOfTaskRemovedSuccess) {
          return CardTaskDetail(
            onRemoveUser: (BuildContext context, UserEntity user) async {
              context
                  .read<TaskBloc>()
                  .add(RemoveUserFromTaskEvent(widget.taskId, user.userId));
            },
            state.updatedTask,
            showActions: true,
            onEdit: onEdit,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCommentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Bình luận',
                style: GoogleFonts.robotoFlex(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              Spacer(),
              // Comment count badge
              BlocBuilder<CommentBloc, CommentState>(
                builder: (context, state) {
                  if (state is CommentLoaded && state.comments.isNotEmpty) {
                    final totalComments = _countTotalComments(state.comments);
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        '$totalComments',
                        style: GoogleFonts.robotoFlex(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),

          SizedBox(height: 20),

          // Comments list
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state is CommentLoading) {
                return _buildLoadingState();
              } else if (state is CommentLoaded) {
                // Refresh task detail when comments are loaded
                context.read<TaskBloc>().add(FetchTaskDetail(widget.taskId));

                if (state.comments.isEmpty) {
                  return _buildEmptyState();
                }
                print('current comment state: $state');

                print(state.comments[0]);

                return _buildCommentsTree(state.comments);
              } else if (state is CommentError) {
                return _buildErrorState(state.message);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

// Helper method
  int _countTotalComments(List<CommentEntity> comments) {
    int total = 0;
    for (var comment in comments) {
      total += 1; // Count the comment itself
      total += _countReplies(comment.replies); // Count its replies recursively
    }
    return total;
  }

  int _countReplies(List<CommentEntity> replies) {
    int total = 0;
    for (var reply in replies) {
      total += 1;
      total += _countReplies(reply.replies);
    }
    return total;
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải bình luận...',
            style: GoogleFonts.robotoFlex(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '💬 Chưa có bình luận nào',
              style: GoogleFonts.robotoFlex(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy là người đầu tiên bình luận!',
              style: GoogleFonts.robotoFlex(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade600,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không thể tải bình luận',
                  style: GoogleFonts.robotoFlex(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.robotoFlex(
                    fontSize: 12,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Retry loading comments
              context
                  .read<CommentBloc>()
                  .add(FetchCommentsEvent(widget.taskId));
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.red.shade600,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTree(List<CommentEntity> comments) {
    return Column(
      children: [
        // Divider
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.grey.shade300,
                Colors.transparent,
              ],
            ),
          ),
        ),

        SizedBox(height: 20),

        // Comments list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (context, index) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final comment = comments[index];
            final isLast = index == comments.length - 1;

            return CommentCard(
              comment: comment,
              isLast: isLast,
              onReply: () {
                // 1️ Lưu parentId
                _replyToParentId = comment.id;

                // 2️ Chèn tên user vào ô input
                _commentController.text = '@${comment.user.name} ';
                _commentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _commentController.text.length),
                );
                if (_targetKey.currentContext != null) {
                  Scrollable.ensureVisible(
                    _targetKey.currentContext!,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  ).then((_) {
                    // Chờ animation scroll
                    Future.delayed(const Duration(milliseconds: 100), () {
                      FocusScope.of(context).requestFocus(_commentFocusNode);
                    });
                  });
                }
              },

              /*   onReply: () => onReply(
                context,
                (parentId) => _handleSendComment(parentId: parentId),
                comment
              ), */
              onLike: () {
                _handleLikeComment(comment);
              },
            );
          },
        ),
      ],
    );
  }

// Helper methods for handling comment actions
  void _handleLikeComment(CommentEntity comment) {
    // Implement like comment logic
    //context.read<CommentBloc>().add(LikeComment(comment.id));
  }

  void onReply(BuildContext context, void Function(String) onSend,
      CommentEntity commentParent) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (bottomContext) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomContext)
                  .viewInsets
                  .bottom, //  Đẩy theo bàn phím
            ),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Bạn đang phản hồi bình luận của ${commentParent.user.name}'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _commentController,
                          style: GoogleFonts.roboto(fontSize: 15),
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(width: 1)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(width: 1)),
                              hintText: 'Viết bình luận...',
                              fillColor: Colors.grey.shade100,
                              filled: true),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: () => onSend(commentParent.id),
                          child: Icon(
                            Icons.send_outlined,
                            size: 30,
                          ))
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildCommentInput() {
    return Row(
      key: _targetKey,
      children: [
        Expanded(
          child: TextFormField(
            focusNode: _commentFocusNode,
            controller: _commentController,
            style: GoogleFonts.roboto(fontSize: 15),
            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(width: 1)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(width: 1)),
                hintText: 'Viết bình luận...',
                fillColor: Colors.grey.shade100,
                filled: true),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _handleSendComment,
        ),
      ],
    );
  }

  void _handleSendComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể để trống')),
      );
      return;
    }
    final userId = context.read<AuthBloc>().user_id;
    final taskId = widget.taskId;

    print(
      '_replyId: $_replyToParentId',
    );

    context
        .read<CommentBloc>()
        .add(CreateComment(content, taskId, userId, _replyToParentId));
    _commentController.clear();
    _replyToParentId = '';
  }
}

/// Transition animation
class SlideRightToLeftRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightToLeftRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
                position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
