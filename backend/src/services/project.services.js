const db = require("../models/index");

const createProject = async (data, callback) => {
  try {
    const {
      name,
      description,
      leader_id,
      status = "Ongoing",
      startDate = new Date(),
      endDate = null,
    } = data;

    const newProject = await db.Project.create({
      name,
      description,
      leader_id,
      status,
      startDate,
      endDate,
    });

    console.log(leader_id);

    await db.ProjectUser.create({
      user_id: leader_id,
      project_id: newProject.id,
      role: "Leader",
    });

    const project = await db.Project.findByPk(newProject.id, {
      include: [
        {
          model: db.ProjectUser,
          as: "project_users",
          include: [
            {
              model: db.User,
              as: "pro_users",
              attributes: ["id", "fullname", "email", "avatar", "birthday"],
            },
          ],
        },
        {
          model: db.Task,
          as: "tasks",
        },
      ],
    });

    const result = {
      project_id: project.id,
      name: project.name,
      description: project.description,
      status: project.status,
      startDate: project.startDate,
      endDate: project.endDate,
      leader_id: project.leader_id,
      color: project.color, // Include color
      numberCompletedTask: project
        .get()
        .tasks.filter((task) => task.status === "Completed").length,
      numberTask: project.get().tasks.length,
      members: project.project_users.map((pu) => ({
        id: pu.pro_users.id,
        name: pu.pro_users.fullname,
        email: pu.pro_users.email,
        avatar: pu.pro_users.avatar,
        birthday: pu.pro_users.birthday,
        role: pu.role, // Include role
      })),
    };

    return callback(null, {
      message: "Created project successfully",
      success: true,
      data: result,
    });
  } catch (error) {
    return callback(error);
  }
};

// Feature 2: Get Danh Sach Project
const getProjects = async (data, callback) => {
  try {
    console.log("HHHHHHHHHHHHHHHHHHHHH");
    const user_id = data.user_id;
    const is_leader = data.is_leader;
    let resultList = [];

    if (is_leader === "true") {
      // Fetch projects where user is leader, including members
      const projects = await db.Project.findAll({
        where: { leader_id: user_id },
        include: [
          {
            model: db.ProjectUser,
            as: "project_users",
            include: [
              {
                model: db.User,
                as: "pro_users",
                attributes: ["id", "fullname", "email", "avatar"],
              },
            ],
          },
          {
            model: db.Task,
            as: "tasks",
          },
        ],
      });

      /* 
       const completedTasks = await db.Project.findAll({
        where: {leader_id: user_id}, 
        include: [
          
          {
          model: db.Task, 
          as: 'tasks',
          where: {
            status: 'Completed'
          }, 
          required: false // dùng LEFT JOIN thay vì INNER JOIN
        }
        ]

      }); 
 */

      // Get so luong project
      // console.log('Số lượng project: ', taskOfProject.get().projects.length)
      //   completedTasks.forEach(project => {
      //console.log('Project:', project.name);
      //console.log('Số lượng task: ', project.get().tasks.length)
      /*  project.tasks.forEach(task => {
    console.log('  Task:', task.title);
  });  */
      //  console.log(completedTasks[0])
      //});

      // Lọc số lượng task đã hoàn thành ...

      resultList = projects.map((item) => ({
        project_id: item.id,
        name: item.name,
        description: item.description,
        status: item.status,
        startDate: item.startDate,
        endDate: item.endDate,
        leader_id: item.leader_id,
        color: item.color, // Include color
        numberCompletedTask: item
          .get()
          .tasks.filter((task) => task.status === "Completed").length,
        numberTask: item.get().tasks.length,
        members: item.project_users.map((pu) => ({
          id: pu.pro_users.id,
          name: pu.pro_users.name,
          email: pu.pro_users.email,
          avatar: pu.pro_users.avatar,
          role: pu.role, // Include role
        })),
      }));
    } else {
      // Fetch projects where user is a member, including all members
      const projectUsers = await db.ProjectUser.findAll({
        where: { user_id: user_id },
        include: [
          {
            model: db.Project,
            as: "project_user",
            include: [
              {
                model: db.ProjectUser,
                as: "project_users",
                include: [
                  {
                    model: db.User,
                    as: "pro_users",
                    attributes: [
                      "id",
                      "fullname",
                      "email",
                      "avatar",
                      "birthday",
                    ],
                  },
                ],
              },

              {
                model: db.Task,
                as: "tasks",
              },
            ],
          },
        ],
      });

      resultList = projectUsers.map((item) => ({
        project_id: item.project_user?.id,
        name: item.project_user?.name,
        description: item.project_user?.description,
        status: item.project_user?.status,
        startDate: item.project_user?.startDate,
        endDate: item.project_user?.endDate,
        leader_id: item.project_user?.leader_id,
        color: item.project_user?.color, // Include color
        numberCompletedTask: item.project_user
          .get()
          .tasks.filter((task) => task.status === "Completed").length,
        numberTask: item.project_user.get().tasks.length,
        members:
          item.project_user?.project_users.map((pu) => ({
            id: pu.pro_users.id,
            name: pu.pro_users.name,
            email: pu.pro_users.email,
            avatar: pu.pro_users.avatar,
            role: pu.role, // Include role
            birthday: pu.pro_users.birthday,
          })) || [],
      }));
    }

    return callback(null, {
      message: "Get List Project Successfully",
      success: true,
      data: resultList, // Fix: Return resultList
    });
  } catch (error) {
    return callback(error);
  }
};

// Feature Add Member Into Group
const addMemberToProject = async (data, callback) => {
  try {
    const { user_id, project_id, leader_id } = data;

    // Lấy thông tin project
    const project = await db.Project.findOne({ where: { id: project_id } });

    if (!project) {
      return callback(null, {
        message: "Project does not exist",
        success: false,
      });
    }

    // Kiểm tra quyền leader
    if (project.leader_id !== leader_id) {
      return callback(null, {
        message: "You do not have permission to add members to this project",
        success: false,
      });
    }

    // Kiểm tra user đã có trong project chưa
    const existingMember = await db.ProjectUser.findOne({
      where: {
        user_id,
        project_id,
      },
    });

    if (existingMember) {
      return callback(null, {
        message: "User is already in the project",
        success: false,
      });
    }

    // Thêm thành viên
    await db.ProjectUser.create({
      project_id,
      user_id,
      role: "Member",
    });

    return callback(null, {
      message: "Member added successfully",
      success: true,
      data: user_id 
    });
  } catch (error) {
    console.error("Error in addMemberToProject:", error);
    return callback(error, {
      message: "Internal Server Error",
      success: false,
    });
  }
};

const fetchMembersOfProject = async (data, callback) => {
  try {
    const user_id = data.user_id;
    const project_id = data.project_id;

    const existProject = await db.Project.findByPk(project_id);
    if (!existProject) {
      return callback(null, {
        message: "Project not found",
        success: false,
      });
    }

    // Check user belongs to project
    const existPermission = await db.ProjectUser.findOne({
      where: {
        user_id: user_id,
        project_id: project_id,
      },
    });

    if (!existPermission) {
      return callback(null, {
        message: "Not Permission",
        success: false,
      });
    }

    const projectWithMembers = await db.Project.findByPk(project_id, {
      include: [
        {
          model: db.ProjectUser,
          as: "project_users",
          include: [
            {
              model: db.User,
              as: "pro_users",
              attributes: [
                "id",
                "avatar",
                "email",
                "fullname",
                "birthday",
                "active",
                "phone",
              ],
            },
          ],
        },
      ],
    });

    console.log(projectWithMembers);

    projectWithMembers.project_users.forEach((item) => {
      console.log(item.pro_users.email);
    });

    // project_id:
    // members: [

    // ]

    return callback(null, {
      data: {
        project_id: projectWithMembers.id,
        leader_id: projectWithMembers.leader_id,
        member: projectWithMembers.project_users.map((item) => ({
          user_id: item.pro_users.id,
          phone: item.pro_users.phone,
          fullname: item.pro_users.fullname,
          email: item.pro_users.email,
          avatar: item.pro_users.avatar,
          project_id: projectWithMembers.id,
          role: item.role, // Include role
          birthday: item.pro_users.birthday,
        })),
      },
      message: "Fetch Members Successfully",
    });
  } catch (error) {}
};

const createProject1 = async (data, callback) => {
  try {
    const leader_id = data.user_id;
    const name = data.name;
    const description = data.description;
    const status = data.status || "OnGoing";
    const startDate = data.startDate || Date.NOW;
    const endDate = data.endDate;

    const project = await db.Project.create({
      name,
      description,
      leader_id,
      startDate,
      endDate,
      status,
    });

    return callback(null, {
      data: project,
      message: "Create Project Successfully!",
      success: true,
    });
  } catch (error) {
    return callback(error);
  }
};

const fetchProjectById = async (data, callback) => {
  try {
    const user_id = data.user_id;
    const project_id = data.project_id;

    // Check permission
    const permission =await db.ProjectUser.findOne({
      where: {
        user_id: user_id,
        project_id: project_id,
      },
    });

    if (!permission) {
      return callback(null, {
        success: false,
        message: "Not Permission",
      });
    }

    const project = await db.Project.findByPk(project_id, {
      include: [
        {
          model: db.ProjectUser,
          as: "project_users",
          include: [
            {
              model: db.User,
              as: "pro_users",
              attributes: ["id", "fullname", "email", "avatar", 'birthday'],
            },
          ],
        },
        {
          model: db.Task,
          as: "tasks",
        },
      ],
    });

    if (!project) {
      return callback(null, {
        message: "Project Not Found",
        success: false 
      });
    }

    console.log(project); 

    return callback(null, {
      message: "Get Project Successfully",
      data: {
        project_id: project.id,
        name: project.name,
        description: project.description,
        status: project.status,
        startDate: project.startDate,
        endDate: project.endDate,
        leader_id: project.leader_id,
        color: project.color, // Include color
       numberCompletedTask: project.tasks.filter((task) => task.status === "Completed").length,

        numberTask: project.get().tasks.length,
        members:
          project?.project_users.map((pu) => ({
            id: pu.pro_users.id,
            name: pu.pro_users.fullname,
            email: pu.pro_users.email,
            avatar: pu.pro_users.avatar,
            role: pu.role, // Include role
            birthday: pu.pro_users.birthday,
          })),
      },
    });
  } catch (error) {
    return callback(error);
  }
};

module.exports = {
  createProject,
  getProjects,
  addMemberToProject,
  fetchMembersOfProject,
  fetchProjectById
  //createProject
};
