const attachmentService = require('../services/attachment.services'); 

const uploadFileForTask = (req,res) => {
    const user_id = req.user.userId; 
    const files = req.files; 
    const task_id= req.params.task_id; 
    const is_main = req.body.is_main; 
    const data = {
        user_id: user_id,files: files,task_id: task_id, 
        is_main: is_main
    
    }

    console.log(data);

    attachmentService.uploadFileForTask(data,(error,result) => {
        if (error) {
            return res.status(500).json(error);
        }
        else if (!result.success) {
            if (result.message.includes('Not Found')) {
                return res.status(404).json(result); 
            }
        }
        return res.status(200).json(result); 
    })

}

module.exports = {
    uploadFileForTask
}