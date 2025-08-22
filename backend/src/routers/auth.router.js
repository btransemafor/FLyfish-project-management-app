const express = require('express');
const router = express.Router();
const {authenticateTokenRefresh} = require('../middleware/authJwt'); 
const authController = require('../controller/auth.controller'); 

router.post('/register', authController.register);
router.post('/login', authController.login);  
router.post('/request-new-accessToken', authenticateTokenRefresh, authController.requireAccessToken  ); 
router.get('/logout', authController.logOut);
module.exports = router; 