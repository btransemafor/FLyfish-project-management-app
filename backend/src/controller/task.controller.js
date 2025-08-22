const TaskService = require("../services/task.services");
const handleServiceResponse = require('../utils/handle_response'); 
const createTaskForProject = (req, res) => {
  const {
    title,
    description,
    priority,
    status,
    dueDate,
    projectId,
    assigneeIds,
  } = req.body;

  const user = req.user;
  const createdBy = user.userId;

  if (!title || !description || !priority || !projectId || !createdBy) {
    return res.status(400).json({ message: "Missing Data" });
  }

  TaskService.createTaskForProject(
    {
      title,
      description,
      priority,
      status,
      dueDate,
      projectId,
      createdBy,
      assigneeIds,
    },
    (error, result) => {
      if (error) {
        return res.status(500).json(error);
      } else if (result.message.includes("not found")) {
        return res.status(404).json(result);
      } else if (
        result.message == "Creator must be a project member or leader"
      ) {
        return res.status(403).json(result);
      }

      return res.status(201).json(result);
    }
  );
};

const getListTasks = (req, res) => {
  debugger;
  const user = req.user;
  const user_id = user.userId;
  console.log(user_id);
  const Rawstatus = req.query.status; // status === '"Not Started"'  <-- lỗi
  const status = Rawstatus?.replace(/^"|"$/g, ""); // bỏ dấu " đầu & cuối
  console.log('[STATUS] : ', status);

  const data = { user_id, status };

  console.log('[DATA] : user_id',user_id, 'status: ', status )
  TaskService.getListTasks(data, (err, result) => {
    if (err) {
      return res.status(500).json({ message: "Server Internal Error" });
    }
    return res.status(200).json(result);
  });
};

const getTasksByProject = (req, res) => {
  const user = req.user;
  const user_id = user.userId;
  const project_id = req.params.projectId;
  console.log(user_id);
  const data = { user_id, project_id };

  if (!project_id) {
    return res.status(400).json({ message: "Missing Data" });
  }
  TaskService.fetchTasksByProject(data, (err, result) => {
    if (err) {
      return res.status(500).json(err);
    } else if (result.message.includes("Exist")) {
      return res.status(404).json(result);
    } else if (result.message.includes("permission")) {
      return res.status(403).json(result);
    }
    return res.status(200).json(result);
  });
};

const updateTask = (req, res) => {
  const taskId = req.params.taskId;
  const updateData = req.body;
  const user_id = req.user.userId;
  console.log(taskId);
  console.log(updateData);

  TaskService.updateTask(taskId, user_id, updateData, (error, result) => {
    if (error) {
      return res.status(500).json(error);
    } else if (result.success == false) {
      if (result.message.includes("not found")) {
        return res.status(404).json(result);
      } else if (result.message.includes("not have permission")) {
        return res.status(403).json(result);
      } else if (result.message.includes("Invalid status value")) {
        return res.status(400).json(result);
      }
    }
    return res.status(200).json(result);
  });
};

const fetchNearestTasks = (req, res) => {
  const userId = req.user.userId;
  const count = parseInt(req.query.nearest, 10) || 5; // Mặc định 5 nếu không truyền

  const data = { user_id: userId };
  console.log(data);

  TaskService.fetchNearestTasks(count, data, (error, result) => {
    if (error) {
      return res.status(500).json({ error: error.message || 'Internal server error' });
    }
    return res.status(200).json(result);
  });
};


const getFilesByTask = (req,res) => {
  const task_id = req.params.task_id;
  const protocol = req.protocol; 
  const host = req.get('host'); 
  const data = {task_id: task_id, protocol, host}

  console.log(data);
  TaskService.getFilesByTask(data, (error, result) => {
    if (error) {
      return res.status(500).json(error); 
    }
    return res.status(200).json(result);
  }) 

}
const fetchTaskById = (req,res) => {
  const userId = req.user.userId;
  const taskId = req.params.taskId;


  const data = { user_id: userId, task_id: taskId };
  console.log(data);

  TaskService.fetchTaskById(data, (error, result) => {
    if (error) {
      return res.status(500).json(error);
    } else if (result.success == false) {
      if (result.message.includes("not found")) {
        return res.status(404).json(result);
      } else if (result.message.includes("have permission")) {
        return res.status(403).json(result);
      }
    }
    return res.status(200).json(result);
  });
}


const fetchTodayTasks = (req,res) => {
  const user_id = req.user.userId; 
  const data = {user_id: user_id}
  console.log(data); 
  TaskService.fetchTodayTasks(data, (error, result) => {
    handleServiceResponse(res,error,result); 
  })
}
const deleteTaskById = (req,res) => {
  const user_id = req.user.userId; 
  const task_id = req.params.taskId; 



  const data = {user_id, task_id}
  console.log(data);
  TaskService.deleteTaskById(data, (error, result) => {
    if (error) {
      return res.status(500).json(error);
    } else if (result.success == false) {
      if (result.message.includes("not found")) {
        return res.status(404).json(result);
      } else if (result.message.includes("not permission")) {
        return res.status(403).json(result);
      }
    }
    return res.status(200).json(result);
  });
}


const removeUserFromTask = (req,res) => {
  const user_id_request = req.user.userId; 
  const { user_id, task_id } = req.body; // người muốn remove + task id
  TaskService.removeUserFromTask({user_id,user_id_request,task_id}, (error, result ) => {
    handleServiceResponse(res, error, result); 
  })
}

module.exports = {
  createTaskForProject,
  getListTasks,
  getTasksByProject,
  updateTask,
  fetchNearestTasks,
  getFilesByTask,
  fetchTaskById,
  deleteTaskById, 
  fetchTodayTasks, 
  removeUserFromTask
};
