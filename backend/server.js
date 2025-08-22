const app = require('./src/index');
const db = require('./src/models');
const server = require('http').createServer(app);
require('dotenv').config();

const {initSocket} = require('./src/socket/index');

const io = initSocket(server);

async function startServer() {
  await db.sequelize.sync({ force: false });

  // Test 

  console.log('Database & tables synced!');
  // In cac model 
  console.log(Object.keys(db.sequelize.models)); 

  // const allUsers = await db.User.findAll();

  // console.log(allUsers)

  server.listen(process.env.PORT || 5000, () => {
    console.log(`Server is running on http://localhost:${process.env.PORT || 5000}`);
  });
}
startServer().catch(err => {
  console.error('Server startup error:', err);
  process.exit(1);
});