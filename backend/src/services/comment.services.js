const db = require("../models/index");

const fetchCommentsByTask = async (data, callback) => {
  try {
    const task_id = data.task_id;
    console.log(task_id);
    const task = await db.Task.findByPk(task_id, {
      include: [
        {
          model: db.Comment,
          as: "comments",
          where: {
            parentId: null,
          },
          separate: true, // giúp sort riêng cho comments
          order: [["createdAt", "ASC"]],
          include: [
            {
              model: db.User,
              as: "cmt_user",
              attributes: ["id", "fullname", "email", "avatar", "birthday"],
            },

            {
              model: db.Comment,
              as: "replies",
              include: [
                {
                  model: db.User,
                  as: "cmt_user",
                  attributes: ["id", "fullname", "email", "avatar", "birthday"],
                },
              ],
            },
          ],
        },
      ],
    });

    console.log(task);

    const result = task.comments.map((cmt) => ({
      id: cmt.id,
      content: cmt.content,
      taskId: cmt.taskId,
      parentId: cmt.parentId,
      user: {
        id: cmt.cmt_user.id,
        name: cmt.cmt_user.fullname,
        birthday: cmt.cmt_user.birthday,
        avatar: cmt.cmt_user.avatar,
        email: cmt.cmt_user.email,
      },
      createdAt: cmt.createdAt,

      replies: cmt.replies.map((item) => ({
        id: item.id,
        content: item.content,
        taskId: item.taskId,
        parentId: item.parentId,
        user: {
          id: item.cmt_user.id,
          name: item.cmt_user.fullname,
          birthday: item.cmt_user.birthday,
          avatar: item.cmt_user.avatar,
          email: item.cmt_user.email,
        },
      })),
    }));

    return callback(null, {
      message: "Fetch Comment Successfully",
      data: result,
      success: true,
    });
  } catch (error) {
    return callback(error);
  }
};

const addComment = async (data, callback) => {
  const NotificationService = require("./notification.services");
  try {
    console.log(data);
    const newComment = await db.Comment.create({
      id: data.id,
      content: data.content,
      taskId: data.task_id,
      userId: data.user_id,
      parentId: data.parent_id,
    });

    const comment = await db.Comment.findByPk(newComment.id, {
      include: [
        {
          model: db.User,
          as: "cmt_user",
          attributes: ["id", "fullname", "email", "avatar", "birthday"],
        },
        {
          model: db.Comment,
          as: "replies",
        },
      ],
    });

    // Lay user duoc gan cho task
    const taskUsers = await db.Task.findOne({
      where: {
        id: newComment.taskId,
      },
      include: [
        {
          model: db.User,
          as: "assignees",
          attributes: ["id", "fullname", "email", "avatar", "birthday"],
        },
      ],
    });

    if (newComment.parent_id == null) {
      await NotificationService.createNotificationForCommentAllTaskUsers(
        comment, taskUsers.assignees
      );
    }
    else {
        // Truy vấn commnet cha
    const parentComment = await db.Comment.findOne({
      where: { id: newComment.parentId },
      include: [
        {
          model: db.User,
          as: "cmt_user",
          attributes: ["id", "fullname", "email", "avatar", "birthday"],
        },
      ],
    });

    //

    await NotificationService.createNotificationForComment(
      comment,
      parentComment
    );

    }

  
    const result = {
      id: comment.id,
      content: comment.content,
      taskId: comment.taskId,
      parentId: comment.parentId,
      user: {
        id: comment.cmt_user.id,
        name: comment.cmt_user.fullname,
        birthday: comment.cmt_user.birthday,
        avatar: comment.cmt_user.avatar,
        email: comment.cmt_user.email,
      },
      replies: comment.replies.map((item) => ({
        id: item.id,
        content: item.content,
        taskId: item.taskId,
        parentId: item.parentId,
        user: {
          id: item.cmt_user.id,
          name: item.cmt_user.fullname,
          birthday: item.cmt_user.birthday,
          avatar: item.cmt_user.avatar,
          email: item.cmt_user.email,
        },
      })),
      createdAt: comment.createdAt,
    };

    console.log("Comment created:", newComment?.dataValues);

    if (callback) callback(null, result);
  } catch (err) {
    console.error("Sequelize insert comment error:", err);
    if (callback) callback(err, null);
  }
};

module.exports = {
  fetchCommentsByTask,
  addComment,
};
