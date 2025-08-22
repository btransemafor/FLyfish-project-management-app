const NotificationService = require('../../services/notification.services'); 

const registerNotificationHandler = (io, socket) => {
    socket.on("joinNotification", (userId) => {
    socket.join(`user_${userId}`);
    console.log(`User ${userId} joined notification room`);
  });

  socket.on("markAsRead", (data) => {
    // Handle mark as read logic
    console.log("Mark as read:", data);
  });
}

module.exports = registerNotificationHandler; 