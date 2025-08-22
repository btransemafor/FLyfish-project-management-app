const nodemailer = require('nodemailer'); 

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "flyfishchill@gmail.com",
    pass: "yoodoxsubohkvhco",
  },
});

async function sendNotificationForTaskCreation(recipients, task) {
    console.log("List Recipients: ",recipients)
  const mailOptions = {
    from: 'flyfishchill@gmail.com',
    to: recipients, // chuỗi hoặc mảng email
    subject: `📢 Thông báo Task mới: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; color: #333; line-height: 1.5; padding: 20px; background: #f9f9f9;">
        <h2 style="color: #2E86C1;">Bạn có một task mới được giao!</h2>
        <p>Chào bạn,</p>
        <p>Dưới đây là thông tin chi tiết về task mới:</p>
        <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
          <tr>
            <td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Tiêu đề</td>
            <td style="padding: 8px; border: 1px solid #ddd;">${task.title}</td>
          </tr>
          <tr>
            <td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Mô tả</td>
            <td style="padding: 8px; border: 1px solid #ddd;">${task.description || 'Không có mô tả'}</td>
          </tr>
          <tr>
            <td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Ưu tiên</td>
            <td style="padding: 8px; border: 1px solid #ddd;">${task.priority}</td>
          </tr>
          <tr>
            <td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Trạng thái</td>
            <td style="padding: 8px; border: 1px solid #ddd;">${task.status}</td>
          </tr>
          <tr>
            <td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Ngày hết hạn</td>
            <td style="padding: 8px; border: 1px solid #ddd;">${task.dueDate ? new Date(task.dueDate).toLocaleDateString() : 'Chưa có'}</td>
          </tr>
          <tr>
            <td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Dự án</td>
            <td style="padding: 8px; border: 1px solid #ddd;">${task.project.name || 'Chưa có'}</td>
          </tr>
        </table>
        <p style="margin-top: 20px;">Vui lòng đăng nhập vào app <strong>Flyfish</strong> để xem và cập nhật task.</p>
        <a href="https://yourappdomain.com/tasks/${task.id}" style="display: inline-block; padding: 10px 20px; background: #2E86C1; color: white; text-decoration: none; border-radius: 5px;">Xem Task</a>
        <p style="margin-top: 40px; font-size: 12px; color: #999;">Nếu bạn không phải người nhận email này, vui lòng bỏ qua.</p>
      </div>
    `,
  };

  try {
    let info = await transporter.sendMail(mailOptions);
    console.log('Email sent: ' + info.response);
  } catch (error) {
    console.error('Error sending mail:', error);
  }
}

/**
 * Gửi email
 * @param {string[]|string} recipients - Danh sách email hoặc 1 email
 * @param {string} subject - Tiêu đề email
 * @param {string} html - Nội dung HTML
 */
async function sendEmail(recipients, subject, html) {
  const mailOptions = {
    from: '"Flyfish Notifications" <flyfishchill@gmail.com>',
    to: recipients,
    subject,
    html,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log(`✅ Email sent: ${info.response}`);
  } catch (error) {
    console.error(`❌ Email send error: ${error.message}`);
  }
}

async function sendStatusChangeEmail(task, oldStatus, newStatus) {
  const subject = `🔄 Cập nhật trạng thái task: ${task.title}`;
  const html = `
    <h2>Trạng thái task đã thay đổi</h2>
    <p><strong>Tiêu đề:</strong> ${task.title}</p>
    <p><strong>Trạng thái cũ:</strong> ${oldStatus}</p>
    <p><strong>Trạng thái mới:</strong> ${newStatus}</p>
    <a href="https://yourappdomain.com/tasks/${task.id}">Xem chi tiết</a>
  `;
  await sendEmail(task.assignees.map(a => a.email), subject, html);
}

async function sendDueDateChangeEmail(task) {
  const subject = `📅 Task ${task.title} đã đổi ngày hết hạn`;
  const html = `
    <h2>Ngày hết hạn của task đã được cập nhật</h2>
    <p><strong>Tiêu đề:</strong> ${task.title}</p>
    <p><strong>Ngày hết hạn mới:</strong> ${task.dueDate ? new Date(task.dueDate).toLocaleDateString() : 'Chưa có'}</p>
    <a href="https://yourappdomain.com/tasks/${task.id}">Xem chi tiết</a>
  `;
  await sendEmail(task.assignees.map(a => a.email), subject, html);
}

async function sendPriorityChangeEmail(task) {
  const subject = `⚡ Task ${task.title} đã đổi độ ưu tiên`;
  const html = `
    <h2>Độ ưu tiên của task đã thay đổi</h2>
    <p><strong>Tiêu đề:</strong> ${task.title}</p>
    <p><strong>Độ ưu tiên mới:</strong> ${task.priority}</p>
    <a href="https://yourappdomain.com/tasks/${task.id}">Xem chi tiết</a>
  `;
  await sendEmail(task.assignees.map(a => a.email), subject, html);
}

async function sendAssigneeChangeEmail(task, newAssigneeIds) {
  const subject = `👥 Task ${task.title} có sự thay đổi người được giao`;
  const html = `
    <h2>Danh sách người được giao task đã thay đổi</h2>
    <p><strong>Tiêu đề:</strong> ${task.title}</p>
    <p>Vui lòng đăng nhập để xem chi tiết danh sách mới.</p>
    <a href="https://yourappdomain.com/tasks/${task.id}">Xem chi tiết</a>
  `;
  await sendEmail(task.assignees.map(a => a.email), subject, html);
}

module.exports = {
  sendStatusChangeEmail,
  sendDueDateChangeEmail,
  sendPriorityChangeEmail,
  sendAssigneeChangeEmail,
  sendNotificationForTaskCreation
};



// yood oxsu bohk vhco