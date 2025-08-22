const { Server } = require("socket.io");
const registerCommentHandler = require("./handlers/comment.handler");
//const registerChatHandler = require('./handlers/chat.handler');
//const registerNotificationHandler = require('./handlers/notification.handler');
const registerNotificationHandler = require("../socket/handlers/notification.handler");

// socket.js
let io;

function initSocket(server) {
  console.log("Khởi tạo Socket");
  io = new Server(server, {
    cors: {
      origin: "*",
    },
  });

  io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    // Gọi từng module handler
    registerCommentHandler(io, socket);
    // registerChatHandler(io, socket);
    registerNotificationHandler(io, socket);

    socket.on("disconnect", () => {
      console.log("User disconnected:", socket.id);
    });
  });

  return io;
}

function getIO() {
  if (!io) {
    throw new Error("Socket.io not initialized!");
  }
  return io;
}

module.exports = { initSocket, getIO };
