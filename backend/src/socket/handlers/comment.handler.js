const db = require("../../models/index");
const CommentService = require("../../services/comment.services");
const registerCommentHandler = (io, socket) => {
  // Khi client gửi comment mới
  socket.on("create_comment", (commentData) => {
    // 1. Lưu comment vào DB (hoặc gọi service xử lý logic)
    const content = commentData.content;
    const task_id = commentData.task_id;
    const user_id = commentData.user_id;
    const parent_id = commentData.parentId; 

    console.log('PARENTID ', parent_id)

    const data = {
      content,
      task_id,
      user_id,
      parent_id
    };
    CommentService.addComment(data, (err, result) => {
      if (err) {
        socket.emit("comment_error", { message: "Failed to create comment" });
      } else {
        // 2. Gửi comment mới đến các client đang kết nối
        console.log(result);
        console.log(data.task_id);
        console.log("[Socket] Emitting to room:", data.task_id);
        io.to(data.task_id).emit("new_comment", result);
      }
    });
  });

  // Optional: Join room theo task để emit cho những người liên quan
  socket.on("join_comment", ({ taskId }) => {
    console.log(`[Socket] Join comment room: ${taskId}`);
    socket.join(taskId);
  });
};

module.exports = registerCommentHandler;
