const NotificationService = require("../services/notification.services");
const handleServiceResponse = require("../utils/handle_response");

const fetchNotifications = (req, res) => {
  const user_id = req.user.userId;
  const data = { user_id: user_id };

  NotificationService.fetchNotification(data, (error, result) => {
    handleServiceResponse(res, error, result);
  });
};

const markReadNotification = (req, res) => {
  const user_id = req.user.userId;
  const notification_id = req.params.notification_id;

  const data = {
    user_id: user_id,
    notification_id: notification_id,
  };

  NotificationService.markReadNotification(data, (error, result) => {
    handleServiceResponse(res, error, result);
  });
};


const deleteNotification = (req,res) => {
    const user_id = req.user.userId;
    const notification_id = req.params.notification_id;
    const data = {user_id, notification_id}; 

    NotificationService.deleteNotification(data, (error, result ) => {
      handleServiceResponse(res,error,result); 
    })
}

const deleteAllNotification = (req, res) => {
  const user_id = req.user.userId;
    const data = {user_id}; 

    NotificationService.deleteNotification(data, (error, result ) => {
      handleServiceResponse(res,error,result); 
    })
}
module.exports = {
  fetchNotifications,
  markReadNotification,
  deleteNotification, 
  deleteAllNotification
};
