const db = require("../models/index");

const uploadFileForTask = async (data, callback) => {
  try {
    const uploadedFiles = data.files;
    const user_id = data.user_id;
    const task_id = data.task_id;
    const is_main = data.is_main; 

    console.log(user_id);
    console.log('IS_MAIN', is_main); 

    if (!uploadedFiles || uploadedFiles.length === 0) {
      return callback(null, {
        message: "No files uploaded",
        success: false,
      });
    }

    const task = await db.Task.findOne({ where: { id: task_id } });
    if (!task) {
      return callback(null, {
        message: "Task not found",
        success: false,
      });
    }

    let list_attachments = [];
    let item;

    const user = await db.User.findByPk(user_id);

    for (const file of uploadedFiles) {
      const file_url = `http://192.168.1.5:5000/uploads/${file.filename}`;

      let attach = await db.Attachment.create({
        taskId: task_id,
        file_name: file.originalname,
        file_url: file_url,
        uploadedBy: user_id,
        is_main: is_main 
      });

      item = {
        id: attach.id,
        name: attach.file_name,
        uploadedBy: attach.uploadedBy,
        url: attach.file_url,
        createdAt: attach.upload_at,
        is_main: attach.is_main,
        uploader: {
          id: user.id,
          name: user.fullname,
          email: user.email,
          birthday: user.birthday,
          avatar: user.avatar,
        },
      };

      list_attachments.push(item);

    }

/*     // Neu chỉ tải 1 file
    if (list_attachments.length == 1) {

    } */

    // Tải nhiều file

    return callback(null, {
      message: "Uploaded files successfully",
      success: true,
      data: list_attachments,
    });
  } catch (error) {
    console.error("Upload error:", error);
    return callback(error);
  }
};

const getFilenameFromURL = (url) => {
  return url.split("/").pop(); // Lấy phần cuối cùng của URL
};

module.exports = {
  uploadFileForTask,
};
