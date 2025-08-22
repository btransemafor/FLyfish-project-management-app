// backend/services/task.service.js
const { DATE } = require("sequelize");
const { Task, Project, User, sequelize } = require("../models");
const db = require("../models/index");
const { Op } = require("sequelize");
const upload = require("../middleware/multer");
const NotificationService = require("./notification.services");
const EmailService = require("./email.services");
const createTaskForProject = async (
  {
    title,
    description,
    priority = "Low",
    status = "Not Started",
    dueDate,
    projectId,
    createdBy,
    assigneeIds = [],
  },
  callback
) => {
  const transaction = await db.sequelize.transaction();
  try {
    // Validate priority and status
    // const validPriorities = ['Low', 'Medium', 'High', 'Urgent'];
    // const validStatuses = ['Not Started', 'In Progress', 'Needs Review', 'Completed'];
    /*     if (!validPriorities.includes(priority)) {
        throw new Error('Invalid priority value');
      }
      if (!validStatuses.includes(status)) {
        throw new Error('Invalid status value');
      } */

    console.log(assigneeIds);

    // Check if project exists and is not hidden
    const project = await db.Project.findOne({
      where: { id: projectId },
      transaction,
    });

    if (!project) {
      return callback(null, {
        message: "Project not found or is hidden",
        success: false,
      });
    }

    // Check if creator exists and is a project member or leader
    const creator = await User.findByPk(createdBy, { transaction });
    if (!creator) {
      return callback(null, {
        message: "Creator not found",
        success: false,
      });
    }
    const isProjectMember = await db.ProjectUser.findOne({
      where: { project_id: projectId, user_id: createdBy },
      transaction,
    });
    if (!isProjectMember && project.leader_id !== createdBy) {
      throw new Error("Creator must be a project member or leader");
    }

    // Validate assignees
    if (assigneeIds.length > 0) {
      const users = await db.User.findAll({
        where: { id: assigneeIds },
        transaction,
      });
      if (users.length !== assigneeIds.length) {
        throw new Error("One or more assignees not found");
      }
      // Ensure assignees are project members
      const projectMembers = await db.ProjectUser.findAll({
        where: { project_id: projectId, user_id: assigneeIds },
        transaction,
      });
    }

    // Create the task
    const task = await Task.create(
      {
        title,
        description,
        priority,
        status,
        dueDate: dueDate ? new Date(dueDate) : null,
        projectId,
        createdBy,
      },
      { transaction }
    );

    console.log("Tạo task thành công");

    // Add assignees to taskAssignee table
    if (assigneeIds.length > 0) {
      await task.addAssignees(assigneeIds, { transaction });
      console.log("Gan Task cho user thanh cong ");
    }

    // Fetch the created task with associations
    const createdTask = await db.Task.findByPk(task.id, {
      include: [
        { model: db.Project, as: "project" },
        {
          model: db.User,
          as: "creator",
          attributes: ["id", "fullname", "email", "avatar", "birthday"],
        },
        {
          model: db.User,
          as: "assignees",
          attributes: ["id", "fullname", "email", "avatar", "birthday"],
        },
      ],
      transaction,
    });

    let recipients = [];
    createdTask.assignees.forEach((item) => {
      recipients.push(item.email);
    });

    console.log(recipients);
    const assigneeUserIds = createdTask.assignees.map((user) => user.id);
    console.log("Đang bắt đầu vào hàm đêt tạo thông báo ");
    await NotificationService.createNotificationForTaskCreation(
      createdTask,
      assigneeUserIds,
      transaction
    );
    console.log("Đang bắt đầu vào hàm tạo email");
    EmailService.sendNotificationForTaskCreation(recipients, createdTask);

    await transaction.commit();

    return callback(null, {
      result: {
        id: createdTask.id,
        title: createdTask.title,
        description: createdTask.description || "",
        priority: createdTask.priority,
        status: createdTask.status,
        dueDate: createdTask.dueDate ? createdTask.dueDate.toISOString() : null,
        projectId: createdTask.projectId,
        projectName: createdTask.project?.name || "",
        creator: {
          id: createdTask.creator.id,
          name: createdTask.creator.fullname,
          email: createdTask.creator.email,
          avatar: createdTask.creator.avatar || "",
          birthday: createdTask.creator.birthday,
        },
        assignees: createdTask.assignees.map((user) => ({
          id: user.id,
          name: user.fullname,
          email: user.email,
          avatar: user.avatar || "",
          birthday: createdTask.creator.birthday,
        })),
        completedAt: createdTask.completedAt
          ? createdTask.completedAt.toISOString()
          : null,
        createdAt: createdTask.createdAt.toISOString(),
        updatedAt: createdTask.updatedAt.toISOString(),
      },
      message: "Created Task Successfully",
      success: true,
    });
  } catch (error) {
    await transaction.rollback();
    return callback(error);
  }
};

const getListTasks = async (data, callback) => {
  const user_id = data.user_id;
  const status = data.status;
  console.log("Status:", status);
  let Tasks = [];

  // Tạo điều kiện động
  const taskWhere = {};
  if (status) {
    taskWhere.status = status;
  }

  try {
    console.log("[DEBUG] Chuẩn bị truy vấn DB");
    const user = await db.User.findByPk(user_id, {
      include: [
        {
          model: db.Task,
          as: "createdTasks",
          where: Object.keys(taskWhere).length ? taskWhere : undefined,
          include: [
            {
              model: db.User,
              as: "creator",
              attributes: ["id", "fullname", "email", "avatar"],
            },
            {
              model: db.User,
              as: "assignees",
              attributes: ["id", "fullname", "email", "avatar"],
              through: { attributes: [] },
            },
          ],
        },
      ],
    });

    Tasks =
      user.createdTasks.map((task) => ({
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        priority: task.priority,
        status: task.status,
        assignees: task.assignees,
        projectId: task.projectId,
        creator: task.creator,
      })) || [];
    console.log("Fetched tasks:", Tasks);

    return callback(null, {
      data: Tasks,
      message: "Success",
    });
  } catch (error) {
    console.error("[ERROR] Get list tasks:", error);
    return callback(error, null);
  }
};

const fetchTasksByProject = async (data, callback) => {
  try {
    const project_id = data.project_id;
    const user_id = data.user_id;

    console.log(project_id, user_id);

    const existProject = await db.Project.findByPk(project_id);
    if (!existProject) {
      return callback(null, {
        message: "Project Not Exist!",
        success: false,
      });
    }

    // Check user belong to project
    const existUserBelongToProject = await db.ProjectUser.findOne({
      where: { user_id, project_id },
    });
    if (!existUserBelongToProject) {
      return callback(null, {
        message: "You do not have permission to get data",
        success: false,
      });
    }

    console.log("Pass cac kiem tra kia ");

    const projectWithTasks = await db.Project.findByPk(project_id, {
      include: [
        {
          model: db.Task,
          as: "tasks",

          //order: [['dueDate', 'ASC']],

          include: [
            {
              model: db.User,
              as: "creator",
              attributes: ["id", "fullname", "email", "avatar", "birthday"],
            },
            {
              model: db.User,
              as: "assignees",
              attributes: ["id", "fullname", "email", "avatar", "birthday"], // Chỉ lấy các trường cần thiết
              through: { attributes: [] }, // Loại bỏ thông tin từ bảng trung gian
            },
          ],
        },
      ],
      order: [[{ model: db.Task, as: "tasks" }, "dueDate", "ASC"]],
    });

    console.log(projectWithTasks);

    return callback(null, {
      success: true,
      message: "Fetch Task Successfully",
      data:
        projectWithTasks.tasks.map((task) => ({
          id: task.id,
          title: task.title,
          description: task.description,
          dueDate: task.dueDate,
          priority: task.priority,
          status: task.status,
          assignees: task.assignees.map((item) => {
            return {
              id: item.id,
              name: item.fullname,
              email: item.email,
              birthday: item.birthday,
              avatar: item.avatar,
            };
          }),

          project: task.project,
          creator: task.creator,
        })) || [],
    });
  } catch (error) {
    return callback(error);
  }
};

// UPdate Task:

const updateTask = async (taskId, userId, updateTask, callback) => {
  try {
    // Validate input
    if (!taskId || !userId || !updateTask) {
      return callback(null, {
        message: "Missing required fields: taskId, userId, or updateTask",
        success: false,
      });
    }

    console.log("Update Task Input:", { taskId, userId, updateTask });

    // Find user
    const user = await db.User.findByPk(userId);
    if (!user) {
      return callback(null, {
        message: "User not found",
        success: false,
      });
    }

    // Find task and its project
    const task = await db.Task.findByPk(taskId, {
      include: [
        {
          model: db.User,
          as: "assignees",
          attributes: ["id", "fullname", "email", "avatar"], // Chỉ lấy các trường cần thiết
          through: { attributes: [] }, // Loại bỏ thông tin từ bảng trung gian
        },
      ],
    });

    const oldTaskData = task.toJSON(); // clone dữ liệu trước update

    console.log(task);
    task.assignees?.forEach((item) => console.log(item.fullname));

    if (!task) {
      return callback(null, {
        message: "Task not found",
        success: false,
      });
    }
    task.assignees.forEach((item) => console.log(item.name));

    const projectId = task.projectId;
    if (!projectId) {
      return callback(null, {
        message: "Task does not belong to any project",
        success: false,
      });
    }

    // Check if user is a project member
    const permission = await db.ProjectUser.findOne({
      where: {
        user_id: userId,
        project_id: projectId,
      },
    });

    if (!permission) {
      return callback(null, {
        message: "User does not have permission to update this task",
        success: false,
      });
    }

    // Validate updateTask fields
    const allowedFields = [
      "title",
      "description",
      "priority",
      "status",
      "dueDate",
      "projectId",
      "createdBy",
      "assigneeIds",
    ];
    const updateFields = Object.keys(updateTask).filter((key) =>
      allowedFields.includes(key)
    );
    if (updateFields.length === 0) {
      return callback(null, {
        message: "No valid fields provided for update",
        success: false,
      });
    }

    // Validate specific fields
    if (
      updateTask.status &&
      !["Not Started", "In Progress", "Completed", "Needs Review"].includes(
        updateTask.status
      )
    ) {
      return callback(null, {
        message: "Invalid status value",
        success: false,
      });
    }
    /// Phân loại thông báo

    // Neu update status Completed or Check lại Só lượng task
    const project = await db.Project.findByPk(projectId, {
      include: [
        {
          model: db.Task,
          as: "tasks", // Đúng với alias bạn định nghĩa trong association
          attributes: ["status"], // Lấy status là đủ
        },
      ],
    });

    // Nếu không tìm thấy project
    if (!project) {
      throw new Error("Project not found");
    }

    // Kiểm tra còn task nào chưa complete không
    const isAllTasksCompleted = project.tasks.every(
      (task) => task.status === "Completed"
    );
    console.log("Đã hoàn thành hết chưa", isAllTasksCompleted);

    if (isAllTasksCompleted) {
      // Cập nhật trạng thái của Project
      await db.Project.update({ status: "Completed" });
      console.log("Project status updated to completed.");
    } else {
      console.log("Not all tasks are completed.");
    }

    if (updateTask.dueDate && isNaN(Date.parse(updateTask.dueDate))) {
      return callback(null, {
        message: "Invalid dueDate format",
        success: false,
      });
    }

    if (updateTask.assigneeIds && !Array.isArray(updateTask.assigneeIds)) {
      return callback(null, {
        message: "assigneeIds must be an array",
        success: false,
      });
    }

    // task.assignees.forEach((item) => console.log(item.name));
    const isExist = task.assignees?.some((item) => item.id === userId);

    if (!isExist && project.leader_id != userId) {
      return callback(null, {
        message: "User does not have permission to assign this task",
        success: false,
      });
    }

    console.log("Bạn có quyền");

    // Update task
    await task.update(updateTask);

    // Custom Thay đổi để gửi email thông báo
    const newTaskData = task.toJSON();

    console.log(newTaskData);

    let updateType = [];

    if (oldTaskData.status !== newTaskData.status) {
      updateType.push("status_changed");
    }

    if (oldTaskData.dueDate !== newTaskData.dueDate) {
      updateType.push("due_date_changed");
    }

    if (oldTaskData.priority !== newTaskData.priority) {
      updateType.push("priority_changed");
    }

    if (
      JSON.stringify(oldTaskData.assignees?.map((a) => a.id).sort()) !==
      JSON.stringify(updateTask.assigneeIds?.sort())
    ) {
      updateType.push("assignees_changed");
    }

    for (let type of updateType) {
      switch (type) {
        case "status_changed":
          // bỏ await để không block main thread
          EmailService.sendStatusChangeEmail(
            newTaskData,
            oldTaskData.status,
            newTaskData.status
          );
          break;
        case "due_date_changed":
          EmailService.sendDueDateChangeEmail(newTaskData);
          break;
        case "priority_changed":
          EmailService.sendPriorityChangeEmail(newTaskData);
          break;
        case "assignees_changed":
          EmailService.sendAssigneeChangeEmail(
            newTaskData,
            updateTask.assigneeIds
          );
          break;
      }
    }

    // Fetch updated task with associations (e.g., assignees)
    const updatedTask = await db.Task.findByPk(taskId, {
      include: [
        {
          model: db.User,
          as: "creator",
          attributes: ["id", "fullname", "email", "avatar"],
        },
        {
          model: db.User,
          as: "assignees",
          attributes: ["id", "fullname", "email", "avatar"], // Chỉ lấy các trường cần thiết
          through: { attributes: [] }, // Loại bỏ thông tin từ bảng trung gian
        },
      ],
    });

    return callback(null, {
      message: "Task updated successfully",
      success: true,
      data: updatedTask,
    });
  } catch (error) {
    console.error("Update Task Error:", error);
    return callback({
      message: "Failed to update task",
      success: false,
      error: error.message,
    });
  }
};

const fetchNearestTasks = async ({ count = 5 }, data, callback) => {
  try {
    const user_id = data.user_id;
    const now = new Date();

    const tasks = await db.Task.findAll({
      where: {
        // createdBy: user_id, // hoặc user_id tuỳ cách đặt FK
        dueDate: {
          [Op.gte]: now,
        },
      },
      order: [["dueDate", "ASC"]],
      limit: count,
      include: [
        {
          model: db.User,
          as: "creator",
          attributes: ["id", "fullname", "email", "avatar"],
        },
        {
          model: db.User,
          as: "assignees",
          attributes: ["id", "fullname", "email", "avatar"],
          through: { attributes: [] },
          where: {
            id: user_id,
          },
        },
      ],
    });

    return callback(null, {
      success: true,
      data: tasks,
    });
  } catch (error) {
    return callback(error);
  }
};

const getFilesByTask = async (data, callback) => {
  try {
    const { task_id, host, protocol } = data;

    const taskWithFiles = await db.Task.findByPk(task_id, {
      include: [
        {
          model: db.Attachment,
          as: "attachments",
          include: [
            {
              model: db.User,
              as: "uploader",
              attributes: ["id", "fullname", "email", "avatar", "birthday"],
            },
          ],
        },
      ],
    });

    if (!taskWithFiles) {
      return callback(null, {
        message: "Task not found",
        success: false,
      });
    }

    const fileInfos = taskWithFiles.attachments.map((file) => ({
      id: file.id,
      name: file.file_name,
      uploadedBy: file.uploadedBy,
      url: `${protocol}://${host}/uploads/${getFilenameFromURL(file.file_url)}`,
      createdAt: file.upload_at,
      is_main: file.is_main,
      uploader: file.uploader
        ? {
            id: file.uploader.id,
            name: file.uploader.fullname,
            email: file.uploader.email,
            birthday: file.uploader.birthday,
            avatar: file.uploader.avatar,
          }
        : null,
    }));
    return callback(null, {
      message: "Fetched Files Successfully",
      success: true,
      data: fileInfos,
    });
  } catch (error) {
    return callback(error);
  }
};

// Helper để lấy filename từ file_url (nếu bạn dùng file_url trong DB)
const getFilenameFromURL = (url) => {
  return url.split("/").pop(); // Lấy phần cuối cùng của URL
};

const fetchTaskById = async (data, callback) => {
  const task_id = data.task_id;
  const user_id = data.user_id;

  // Lay project id cua task
  const task = await db.Task.findOne({
    where: { id: task_id },
    include: [
      {
        model: db.User,
        as: "creator",
        attributes: ["id", "fullname", "email", "avatar", "birthday"],
      },
      {
        model: db.User,
        as: "assignees",
        attributes: ["id", "fullname", "email", "avatar", "birthday"],
        through: { attributes: [] }, // Loại bỏ thông tin từ bảng trung gian
      },
    ],
  });

  if (!task) {
    return callback(null, {
      success: false,
      message: "Task not found",
    });
  }

  const project_id = task.projectId;

  // Check permission
  const permission = await db.ProjectUser.findOne({
    where: {
      user_id: user_id,
      project_id: project_id,
    },
  });

  if (!permission) {
    return callback(null, {
      success: false,
      message: "You dont have permission",
    });
  }

  const result = {
    id: task.id,
    title: task.title,
    description: task.description,
    dueDate: task.dueDate,
    priority: task.priority,
    status: task.status,
    projectId: project_id,
    assignees: task.assignees.map((item) => {
      return {
        id: item.id,
        name: item.fullname,
        email: item.email,
        birthday: item.birthday,
        avatar: item.avatar,
      };
    }),
    creator: {
      id: task.creator.id,
      name: task.creator.fullname,
      email: task.creator.email,
      birthday: task.creator.birthday,
      avatar: task.creator.avatar,
    },
  };

  return callback(null, {
    message: "Fetched Detailed Task Successfully",
    success: true,
    data: result,
  });
};

const deleteTaskById = async (data, callback) => {
  try {
    const task_id = data.task_id;
    const user_id = data.user_id;

    const task = await db.Task.findOne({ where: { id: task_id } });

    if (!task) {
      return callback(null, {
        message: "Task not found",
        success: false,
      });
    }
    console.log("Task Existing");

    const project_id = task.projectId;

    console.log(project_id);

    const permission = await db.ProjectUser.findOne({
      where: {
        project_id: project_id,
        user_id: user_id,
        role: "Leader",
      },
    });

    const is_creator = task.createdBy;
    console.log("Created By: ", is_creator);

    if (!permission && is_creator != user_id) {
      return callback(null, {
        message: "not permission",
        success: true,
      });
    }

    // Pass cac dieu kien

    await db.Task.destroy({ where: { id: task_id } });
    return callback(null, {
      message: "Deleted Task Successfully",
      success: true,
    });
  } catch (error) {
    return callback(error);
  }
};

// Fetch Today Task
const fetchTodayTasks = async (data, callback) => {
  try {
    console.log("[User]: ", data.user_id);
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);

    const existing = await db.User.findByPk(data.user_id);
    if (!existing)
      return callback(null, { success: false, message: "user not found" });
    console.log("User tồn tại");

    const user = await db.User.findAll({
      where: { id: data.user_id },
      include: [
        {
          model: db.Task,
          as: "assignedTasks",
          where: {
            dueDate: {
              [Op.gte]: startOfDay,
              [Op.lte]: endOfDay,
            },
          },

          through: { attributes: [] },
          include: [
            {
              model: db.User,
              as: "assignees",
              attributes: ["id", "fullname", "email", "avatar", 'birthday'],
              through: { attributes: [] },
            },
            {
              model: db.User,
              as: "creator",
              attributes: ["id", "fullname", "email", "avatar", 'birthday'],
            },
          ],
        },
      ],
    });
    /* {
       "id": user.assignedTasks 
       "title": "Hát 100 bài hát 😚🙂‍↕️🙄😌🙂‍↕️😌😏🙄",
       "description": "- Nhớ quay lại clip",
       "dueDate": "2025-08-13T23:31:00.000Z",
       "priority": "Medium",
       "status": "Completed",
       assignees: []
    }; 
 */

   const result = user[0].assignedTasks.map((taskItem) => ({
  id: taskItem.id,
  title: taskItem.title,
  description: taskItem.description,
  dueDate: taskItem.dueDate,
  priority: taskItem.priority,
  status: taskItem.status,
  assignees: taskItem.assignees.map((user) => ({
    id: user.id,
    name: user.fullname,
    email: user.email,
    avatar: user.avatar,
    phone: user.phone ?? "",
    birthday: user.birthday,
  })),

  creator: taskItem.creator
    ? {
        id: taskItem.creator.id,
        name: taskItem.creator.fullname,
        email: taskItem.creator.email,
        avatar: taskItem.creator.avatar,
        phone: taskItem.creator.phone ?? "",
        birthday: taskItem.creator.birthday,
      }
    : null,
}));

    return callback(null, { success: true, data: result ?? [] });
  } catch (err) {
    console.error(err);
    return callback(null, { success: false, message: "server error" });
  }
};

const checkUser = async (user_id, callback) => {
  const user = await db.User.findOne({
    where: {
      id: user_id,
    },
  });
  if (!user) {
    return callback(null, {
      message: "user not found",
      success: false,
    });
  }
};

/// =========== DELETE USER ĐƯỢC GÁN CHO TASK ============== ///
const removeUserFromTask = async (
  { user_id, user_id_request, task_id },
  callback
) => {
  // Lấy user object từ DB
  const userToRemove = await db.User.findByPk(user_id);

  if (!userToRemove) {
    return callback(null, { message: "User không tồn tại", success: false });
  }
  // Check Existing Task
  const task = await db.Task.findOne({
    where: {
      id: task_id,
    },
    include: [
      {
        model: db.User,
        as: "assignees",
        attributes: ["id", "fullname", "email", "avatar"],
        through: { attributes: [] },
      },
      {
        model: db.User,
        as: "creator",
        attributes: ["id", "fullname", "email", "avatar"],
      },
    ],
  });
  if (!task) {
    return callback(null, {
      message: "not permission",
      success: false,
    });
  }

  if (user_id_request === user_id && user_id_request !== task.creator.id) {
    return callback(null, {
      message: "Bạn không thể xóa chính mình, trừ khi bạn là người tạo Task",
      success: false,
    });
  }

  await task.removeAssignees(userToRemove);
  return callback(null, {
    message: "Xóa user khỏi task thành công",
    success: true,
  });
};

module.exports = {
  createTaskForProject,
  getListTasks,
  fetchTasksByProject,
  updateTask,
  fetchNearestTasks,
  getFilesByTask,
  fetchTaskById,
  deleteTaskById,
  fetchTodayTasks,
  removeUserFromTask,
};
