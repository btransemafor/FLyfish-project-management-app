const express = require('express'); 
const NotificationController = require('../controller/notification.controller'); 
const Router = express.Router(); 
Router.get('/',NotificationController.fetchNotifications); 
Router.delete('/:notification_id', NotificationController.deleteNotification);
Router.delete('/', NotificationController.deleteAllNotification);
Router.get('/:notification_id/mark-read/', NotificationController.markReadNotification); 

module.exports = Router; 
