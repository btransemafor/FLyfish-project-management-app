const express = require('express'); 
const ProjectController = require('../controller/project.controller'); 
const router = express.Router(); 
const TaskController = require('../controller/task.controller'); 
router.post('/', ProjectController.createProject);
router.get('/', ProjectController.getProjects);
router.post('/add-member', ProjectController.addMemberToProject);
router.get('/:projectId/members', ProjectController.fetchMemberOfProject); 
router.get('/:project_id', ProjectController.fetchProjectById )
router.get('/:projectId/tasks', TaskController.getTasksByProject), 
module.exports = router;