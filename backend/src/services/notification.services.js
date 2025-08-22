const db = require("../models/index");
const { getIO } = require("../socket/index");
async function createNotificationForTaskCreation(task, assigneeIds = [], transaction) {
  try {
    // Log đầu vào
    console.log("🚀 Bắt đầu tạo notification cho task:", task.id);
    console.log("Assignee IDs:", assigneeIds);

    // Tạo notification chính
    const notification = await db.Notification.create(
      {
        title: "Bạn có task mới được giao",
        message: `Task "${task.title}" đã được tạo và giao cho bạn.`,
        type: "task",
        relatedId: task.id,
        priority: "medium",
        deliveryMethod: { push: true, email: true },
      },
      { transaction }
    );

    console.log("✅ Notification được tạo với ID:", notification.id);

    // Nếu không có assignee thì return luôn
    if (!assigneeIds.length) {
      console.log("Không có user nào được gán task, bỏ qua tạo recipients.");
      return notification;
    }

    // Tạo recipients
    const recipients = assigneeIds.map((userId) => {
      console.log("Tạo recipient cho userId:", userId);
      return {
        userId,
        notificationId: notification.id,
        isRead: false,
      };
    });

    await db.NotificationRecipient.bulkCreate(recipients, { transaction });
    console.log(`✅ Created NotificationRecipient cho ${recipients.length} users`);

    // Lấy instance socket.io
    let io;
    try {
      io = getIO();
      console.log("Socket.io instance obtained:", !!io);
    } catch (e) {
      console.error("❌ Error getting IO:", e);
      return notification;
    }

    // Emit real-time notification
    for (const recipient of recipients) {
      const payload = {
        id: notification.id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        isRead: false,
        relatedId: notification.relatedId,
        createdAt: notification.createdAt,
      };

      try {
        console.log("📢 Emit notification:new to user:", recipient.userId, "payload:", payload);
        io.to(`user_${recipient.userId}`).emit("notification:new", payload);
      } catch (err) {
        console.error("❌ Emit notification lỗi cho user:", recipient.userId, err);
      }
    }

    console.log("Tất cả notifications đã emit thành công");
    return notification; 
  } catch (err) {
    console.error("Tạo notification lỗi:", err);
    throw err;
  }
}

async function createNotificationForTaskUpdate(task, assigneeIds) {
  // Tạo thông báo cho việc cập nhật task
  const notification = await db.Notification.create({
    title: "Task được cập nhật",
    message: `Task "${task.title}" vừa được cập nhật.`,
    type: "task",
    relatedId: task.id,
    priority: "medium",
    deliveryMethod: { push: true, email: true },
  });

  // Tạo recipients cho tất cả assignees
  if (assigneeIds.length > 0) {
    const recipients = assigneeIds.map((userId) => ({
      userId,
      notificationId: notification.id,
      isRead: false,
    }));

    await db.NotificationRecipient.bulkCreate(recipients);

    // Gửi notification tới từng assignee
    recipients.forEach((recipient) => {
      // Chuẩn bị payload nếu cần
      const payload = {
        id: notification.id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        isRead: false,
        relatedId: notification.relatedId,
        createdAt: recipient.createdAt,
      };

      /*           const result = {
    id: notifi.id,
    title: notifi.notification.title,
    message: notifi.notification.message,
    type: notifi.notification.type,
    isRead: notifi.isRead,
    relatedId: notifi.notification.relatedId,
    createdAt: noti.createdAt,
  }; */

      console.log(
        "Emitting notification:new to user:",
        recipient.userId,
        "payload:",
        payload
      );

      io.to(`user_${recipient.userId}`).emit("notification:new", payload);
    });

    console.log("--- createNotificationForTaskUpdate END ---");
  }
}
async function createNotificationForComment(comment, commentParent) {
  console.log("--- createNotificationForComment START ---");
  console.log("Comment:", comment);
  console.log("Comment Parent:", commentParent);

  const notification = await db.Notification.create({
    title: `Có phản hồi mới từ ${comment.cmt_user.fullname}`,
    message: `${comment.cmt_user.fullname} đã trả lời bình luận của bạn: "${comment.content}"`,
    relatedId: comment.taskId,
    priority: "medium",
    type: "comment",
    deliveryMethod: { push: true, email: true },
  });

  console.log("Notification created:", notification.id);

  const recipient = {
    userId: commentParent.cmt_user.id,
    notificationId: notification.id,
    isRead: false,
  };

  const noti = await db.NotificationRecipient.create(recipient);
  console.log("NotificationRecipient created:", noti.id);

  const notifi = await db.NotificationRecipient.findOne({
    where: { id: noti.id },
    include: [{ model: db.Notification, as: "notification" }],
  });

  console.log("NotificationRecipient with include:", notifi);

  // Gửi socket real-time tới user được assign
  let io;
  try {
    io = getIO();
    console.log("Socket.io instance obtained:", !!io);
  } catch (e) {
    console.error("Error getting IO:", e);
    return;
  }

  const result = {
    id: notifi.id,
    title: notifi.notification.title,
    message: notifi.notification.message,
    type: notifi.notification.type,
    isRead: notifi.isRead,
    relatedId: notifi.notification.relatedId,
    createdAt: noti.createdAt,
  };

  console.log(
    "Emitting notification:new to user:",
    recipient.userId,
    "payload:",
    result
  );

  io.to(`user_${recipient.userId}`).emit("notification:new", result);

  console.log("--- createNotificationForComment END ---");
}

const fetchNotification = async (data, callback) => {
  const user_id = data.user_id;
  const user = await db.User.findByPk(user_id, {
    include: [
      {
        model: db.NotificationRecipient,
        as: "notifications",
        include: [
          {
            model: db.Notification,
            as: "notification",
          },
        ],
      },
    ],
  });

  const result = user.notifications.map((noti) => ({
    id: noti.id,
    title: noti.notification.title,
    message: noti.notification.message,
    type: noti.notification.type,
    isRead: noti.isRead,
    relatedId: noti.notification.relatedId,
    createdAt: noti.createdAt,
  }));

  console.log(user.notifications);

  return callback(null, {
    message: "Fetched Noti successfully",
    data: result,
  });
};

// update
const markReadNotification = async (data, callback) => {
  try {
    const { user_id, notification_id } = data;

    // 1. Check user tồn tại
    const user = await db.User.findByPk(user_id);
    if (!user) {
      return callback(null, {
        message: "User not found",
        success: false,
      });
    }

    // 2. Check quyền truy cập notification
    const recipient = await db.NotificationRecipient.findOne({
      where: {
        userId: user_id,
        id: notification_id,
      },
    });

    if (!recipient) {
      return callback(null, {
        message: "No permission or notification not found",
        success: false,
      });
    }

    // 3. Update isRead
    await db.NotificationRecipient.update(
      { isRead: true },
      {
        where: {
          userId: user_id,
          id: notification_id,
        },
      }
    );

    return callback(null, {
      message: "Marked notification as read",
      success: true,
    });
  } catch (error) {
    console.error(error);
    return callback(error, {
      message: "Server error",
      success: false,
    });
  }
};
// ================ DELETE TASK ================= // 


async function createNotificationForCommentAllTaskUsers(comment, taskUsers) {
  console.log("--- createNotificationForCommentAllTaskUsers START ---");
  console.log("Comment:", comment);
  console.log("Task Users:", taskUsers.map(u => u.id));

  // 1. Tạo Notification chung
  const notification = await db.Notification.create({
    title: `Có một bình luận từ ${comment.cmt_user.fullname} trong nhiệm vụ của bạn`,
    message: `${comment.cmt_user.fullname} đã trả lời bình luận: "${comment.content}"`,
    relatedId: comment.taskId,
    priority: "medium",
    type: "comment",
    deliveryMethod: { push: true, email: true },
  });

  console.log("Notification created:", notification.id);

  // 2. Tạo NotificationRecipient cho tất cả user trong task
  const recipients = taskUsers.map(user => ({
    userId: user.id,
    notificationId: notification.id,
    isRead: false,
  }));

  const notiRecipients = await db.NotificationRecipient.bulkCreate(recipients, {
    returning: true,
  });

  console.log("NotificationRecipients created:", notiRecipients.map(n => n.id));

  // 3. Gửi socket real-time tới từng user
  let io;
  try {
    io = getIO();
    console.log("Socket.io instance obtained:", !!io);
  } catch (e) {
    console.error("Error getting IO:", e);
    return;
  }

  notiRecipients.forEach(noti => {
    const result = {
      id: noti.id,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      isRead: noti.isRead,
      relatedId: notification.relatedId,
      createdAt: noti.createdAt,
    };

    console.log("Emitting notification:new to user:", noti.userId, "payload:", result);
    io.to(`user_${noti.userId}`).emit("notification:new", result);
  });

  console.log("--- createNotificationForCommentAllTaskUsers END ---");
}


const deleteNotification = async (data, callback) => {
  const { user_id, notification_id } = data;

  if (!notification_id) {
    // Xóa tất cả thông báo của user
    await db.NotificationRecipient.destroy({ where: { userId: user_id } });
  } else {
    // Xóa thông báo cụ thể
    await db.NotificationRecipient.destroy({
      where: { userId: user_id, id: notification_id },
    });
  }

  return callback(null, {
    message: 'Deleted Notification Successfully',
    success: true,
  });
};

module.exports = {
  createNotificationForTaskCreation,
  createNotificationForTaskUpdate,
  createNotificationForComment,
  fetchNotification,
  markReadNotification,
  deleteNotification, 
  createNotificationForCommentAllTaskUsers
};
