const express = require('express'); 
const router = express.Router(); 
const upload = require('../middleware/multer');
const AttachmentController = require('../controller/attachment.controller'); 
router.post('/', upload.array('files'), AttachmentController.uploadFileForTask);