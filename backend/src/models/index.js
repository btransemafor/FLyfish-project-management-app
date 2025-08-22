// src/models/index.js
const sequelize = require('../config/db');

const User = require('./user.model');
const Project = require('./project.model');
const ProjectUser = require('./project_user.model');
const Task = require('./task.model'); 
const Attachment = require('./attachment.model'); 
const Comment = require('./comment.model'); 
const Notification = require('./notification.model'); 
const NotificationRecipient = require('./notification_recipient.model');
const Token = require('./token');
// Define associations
// Project has one Leader (User)
Project.belongsTo(User, { as: 'leader', foreignKey: 'leader_id' });

// Project has many members (Users) through ProjectUser
Project.belongsToMany(User, {
  as: 'members',
  through: 'ProjectUser',
  foreignKey: 'project_id',
  otherKey: 'user_id',
});

// User can be a member of many projects
User.belongsToMany(Project, {
  as: 'memberProjects',
  through: 'ProjectUser',
  foreignKey: 'user_id',
  otherKey: 'project_id',
});

// ProjectUser belongs to Project and User
ProjectUser.belongsTo(Project, { foreignKey: 'project_id', as: 'project_user' });
ProjectUser.belongsTo(User, { foreignKey: 'user_id', as: 'pro_users' });

// Project has many ProjectUser entries
Project.hasMany(ProjectUser, { as: 'project_users', foreignKey: 'project_id' });
Project.hasMany(Task, {foreignKey: 'projectId', as: 'tasks'})


Task.belongsTo(Project, { foreignKey: 'projectId', as: 'project' });
Task.belongsTo(User, { foreignKey: 'createdBy', as: 'creator' });
Task.belongsToMany(User, {
  through: 'taskAssignee',
  foreignKey: 'task_id',
  otherKey: 'user_id',
  as: 'assignees'
});

// Quan hệ ngược
User.hasMany(Task, { foreignKey: 'createdBy', as: 'createdTasks' }); // Task do user tạo
User.belongsToMany(Task, {
  through: 'taskAssignee',
  foreignKey: 'user_id',
  otherKey: 'task_id',
  as: 'assignedTasks' // Task user được gán
});


//User.hasMany(Task, { as: 'tasks', foreignKey: 'user_id' }); // User tạo nhiều Task

// Association User - Attachment - Task 
// (p1) Tao File 
Attachment.belongsTo(User, {foreignKey: 'uploadedBy', as: 'uploader'}); 
// (p2) 1 task co nhieu Attachment 
Task.hasMany(Attachment, {foreignKey: 'taskId', as: 'attachments'}); 

// Association 
// Task - Comment
Task.hasMany(Comment, { foreignKey: 'taskId', as: 'comments' });
Comment.belongsTo(Task, { foreignKey: 'taskId', as: 'cmt_task' });

// User - Comment
User.hasMany(Comment, { foreignKey: 'userId', as: 'userComments' });
Comment.belongsTo(User, { foreignKey: 'userId', as: 'cmt_user' });
Comment.hasMany(Comment, {foreignKey: 'parentId', as: 'replies'})


// Associations
//Notification.hasMany(NotificationRecipient, { foreignKey: 'notificationId', as: 'recipients' });
NotificationRecipient.belongsTo(Notification, { foreignKey: 'notificationId', as: 'notification'});
Notification.hasMany(NotificationRecipient, {foreignKey: 'notificationId', as: 'recipients'});

User.hasMany(NotificationRecipient, {foreignKey: 'userId', as: 'notifications'}); 


Token.belongsTo(User,{foreignKey: 'userId',as:'tokenOfUser'})

const db = {};
db.sequelize = sequelize;
db.User = User;
db.Project = Project;
db.ProjectUser = ProjectUser;
db.Task = Task; 
db.Attachment = Attachment; 
db.Comment = Comment; 
db.Notification = Notification; 
db.NotificationRecipient = NotificationRecipient; 
db.Token = Token

// Gọi hàm sync nếu muốn tạo bảng (nên để trong server.js hoặc app.js)
// await sequelize.sync();

module.exports = db;