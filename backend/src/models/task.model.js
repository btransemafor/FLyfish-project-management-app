// models/task.js
const { DataTypes, Model } = require('sequelize');
const sequelize = require('../config/db');

class Task extends Model {}

Task.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        len: [3, 255], // Minimum 3 characters, max 255
      },
    },
    description: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    priority: {
      type: DataTypes.ENUM(['Low', 'Medium', 'High', 'Urgent']),
      allowNull: false,
      defaultValue: 'Low',
    },
    status: {
      type: DataTypes.ENUM(['Not Started', 'In Progress', 'Needs Review', 'Completed']),
      allowNull: false,
      defaultValue: 'Not Started',
    },
    dueDate: {
      type: DataTypes.DATE,
      allowNull: true,
    },
/*     projectId: {
      type: DataTypes.UUID,
      allowNull: false
    },
    assigneeId: {
      type: DataTypes.UUID,
      allowNull: true,
    },
    createdBy: {
      type: DataTypes.UUID,
      allowNull: false,
    }, */
    completedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    deletedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    sequelize,
    tableName: 'tasks',
    modelName: 'Task',
    timestamps: true,
    paranoid: true, // Enables soft deletes (uses deletedAt)
   /*  indexes: [
      { fields: ['projectId'] },
      { fields: ['assigneeId'] },
      { fields: ['dueDate'] },
    ], */
  }
);

module.exports = Task;