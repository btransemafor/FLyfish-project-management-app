// D:\todo_project\backend\src\config\db.js
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_DATABASE || 'todo',
  process.env.DB_USERNAME || 'omgnice',
  process.env.DB_PASSWORD || 'omgnice@123',
  {
    dialect: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    logging: false,
    dialectOptions: {
      ssl: process.env.DB_SSL === 'true' ? { require: true, rejectUnauthorized: false } : false,
      clientMinMessages: 'notice',
    },
  }
);

module.exports = sequelize