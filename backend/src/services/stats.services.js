const db = require("../models/index");
const getStatsOverviewUser = async (data, callback) => {
  try {
    const user_id = data.user_id;
    // Get Tong so du an

    const statsUser = await db.User.findOne({
      where: {
        id: user_id,
      },
      include: [
        {
          model: db.Project,
          as: "memberProjects",
          include: [
            {
              model: db.Task,
              as: "tasks",
              order: [["dueDate", "ASC"]],
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
            },
          ],
        },
        {
          model: db.Task,
          as: "assignedTasks",
          through: { attributes: [] },
          //vì assignedTask chỉ là junc table trung gian nên cần thêm dòng này để  bỏ cột từ bảng trung gian nếu không cần,
          order: [["dueDate", "ASC"]],
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
        },
      ],
    });

    // Tổng số project
    const countProject = statsUser.memberProjects.length;
    // Tổng số task được assign trực tiếp
    const countAssignedTask = statsUser.assignedTasks.length;
    // Từng project lấy từng số Task
    // Số task của từng project mà user được gán
    const tasksPerProject = statsUser.memberProjects.map((project) => {
      // Lọc các task mà user_id có trong assignees
      const assignedTasksInProject = project.tasks.filter((task) =>
        task.assignees?.some((assignee) => assignee.id === user_id)
      );

      return {
        projectId: project.id,
        projectName: project.name,
        taskCount: assignedTasksInProject.length,
      };
    });

    // // Get Total Tasks Today

    const today = new Date();
    const todayTask = statsUser.assignedTasks.filter((task) => {
      const due = new Date(task.dueDate);
      return due.toDateString() === today.toDateString();
    });

    const totalTodayTasks = todayTask.length;

    return callback(null, {
      message: "Get Stats Overview User Successfully",
      data: {
        user_id: user_id,
        totalProject: countProject,
        totalTask: countAssignedTask,
        totalTodayTask: totalTodayTasks,
        listTaskToday: todayTask,
      },
    });
  } catch (error) {
    return callback(error);
  }
};

module.exports = {
  getStatsOverviewUser,
};
