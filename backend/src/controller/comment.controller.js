const CommentService = require('../services/comment.services'); 
const fetchCommentsByTask = (req,res) => {
    const task_id = req.params.taskId; 
    const user_id = req.user.userId; 
    const data = {task_id: task_id, user_id: user_id}; 
    CommentService.fetchCommentsByTask(data,(error, result) => {
         if (error) {
            return res.status(500).json(error);
        }
        else if (!result.success) {
            if (result.message.includes('Not Found')) {
                return res.status(404).json(result); 
            }
            else if (result.message.includes('Not Permission')) {
                return res.status(403).json(result)
            }
        }
        return res.status(200).json(result); 
    })
}

const addComment = (req, res) => {
    const content = req.body.content;
    const task_id = req.params.taskId; 
    const user_id = req.user.userId;
    const parent_id = req.body.parentId; 
    const data = {content: content, task_id: task_id, user_id: user_id, 
        parent_id: parent_id
    }; 

    CommentService.addComment(data, (error, result) => {
        if (error) {
            return res.status(500).json({ success: false, message: 'Lỗi server', error });
        }
         // Emit tới các client đã join room `taskId`
        const io = getIO();
        io.to(taskId).emit("new_comment", newComment);
        return res.status(201).json({ success: true, message: 'Bình luận đã được thêm', data: result });
    });
};

module.exports = {
    fetchCommentsByTask, 
    addComment
}