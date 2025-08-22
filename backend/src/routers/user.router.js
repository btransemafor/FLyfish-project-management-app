const express = require('express'); 
const router = express.Router(); 
const userController = require('../controller/user.controller'); 
const statsController = require('../controller/stats.controller');
router.get('/search', userController.searchUser); 
router.get('/stats-overview', statsController.getStatsOverviewUser);
module.exports = router; 