import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do/features/comments/domain/entity/comment_entity.dart';
import 'package:to_do/features/comments/presentation/widget/comment_card.dart';

class CommentTestScreen extends StatefulWidget {
  const CommentTestScreen({super.key});

  @override
  State<CommentTestScreen> createState() => _CommentTestScreenState();
}

class _CommentTestScreenState extends State<CommentTestScreen> {
  String state = "comments"; // "empty", "error", "comments"

/*   List<CommentEntity> sampleComments = [
    CommentEntity(
      taskId: '1',
      id: "1",
      content: "Bình luận chính số 1",
      createdAt: DateTime.now().subtract(Duration(minutes: 5)),
      user: UserEntity(id: "u1", name: "Nguyễn Văn A", avatar: null),
      replies: [
        CommentEntity(
           taskId: '1',
          id: "1-1",
          content: "Trả lời cho bình luận số 1",
          createdAt: DateTime.now().subtract(Duration(minutes: 3)),
          user: UserEntity(id: "u2", name: "Trần Thị B", avatar: null),
          replies: [],
        ),
      ],
    ),
    CommentEntity(
      id: "2",
      content: "Bình luận chính số 2",
      createdAt: DateTime.now().subtract(Duration(minutes: 1)),
      user: UserEntity(id: "u3", name: "Lê Văn C", avatar: null),
      replies: [],
    ),
  ]; */

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        '💬 Chưa có bình luận nào',
        style: GoogleFonts.robotoFlex(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Text(
        '❌ Lỗi: $message',
        style: GoogleFonts.robotoFlex(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _buildCommentsTree(List<CommentEntity> comments) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return CommentCard(
          comment: comment,
          isLast: index == comments.length - 1,
          onReply: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Reply to: ${comment.id}")),
            );
          },
          onLike: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Like: ${comment.id}")),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (state == "empty") {
      body = _buildEmptyState();
    } else if (state == "error") {
      body = _buildErrorState("Không thể tải bình luận");
    } else {
      body = _buildCommentsTree(CommentEntity.mockComments);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Test CommentCard"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                state = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "comments", child: Text("Hiển thị bình luận")),
              PopupMenuItem(value: "empty", child: Text("Empty state")),
              PopupMenuItem(value: "error", child: Text("Error state")),
            ],
          ),
        ],
      ),
      body: body,
    );
  }
}

