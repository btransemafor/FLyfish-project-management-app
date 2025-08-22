const express = require('express'); 
const Router = express.Router(); 
const TaskController = require('../controller/task.controller'); 
const AttachmentController = require('../controller/attachment.controller'); 
const CommentController = require('../controller/comment.controller');
const upload = require('../middleware/multer'); 
Router.get('/task-today', TaskController.fetchTodayTasks); 
Router.post('/', TaskController.createTaskForProject); 
Router.get('/', TaskController.getListTasks);
Router.get('/nearest',TaskController.fetchNearestTasks);

Router.get('/:taskId', TaskController.fetchTaskById); 
Router.get('/:task_id/attachments', TaskController.getFilesByTask); 


Router.patch('/:taskId', TaskController.updateTask); 
Router.post('/:task_id/attachments', upload.array('files'), AttachmentController.uploadFileForTask); 
Router.get('/:taskId/comments', CommentController.fetchCommentsByTask);
Router.post('/:taskId/add-comment', CommentController.addComment);
Router.delete('/remove-user-from-task',TaskController.removeUserFromTask );
Router.delete('/:taskId', TaskController.deleteTaskById); 

module.exports = Router; 