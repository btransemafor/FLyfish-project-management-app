// models/ProjectUser.js
const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/db'); // tùy theo cách tổ chức project của bé

class ProjectUser extends Model {}

ProjectUser.init({
  user_id: {
    type: DataTypes.UUID,
    primaryKey: true,
  },
  project_id: {
    type: DataTypes.UUID,
    primaryKey: true,
  },
  role: {
    type: DataTypes.ENUM("Leader", "Member", "Observer"),
    allowNull: false,
    defaultValue: 'Member',
  },
}, {
  sequelize,
  modelName: 'ProjectUser',
  tableName: 'project_users',
  timestamps: true,
});

module.exports = ProjectUser;
