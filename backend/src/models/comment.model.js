const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

class Comment extends Model {}

Comment.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
   /*  taskId: {
      type: DataTypes.UUID,
      allowNull: false,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
    }, */
  },
  {
    sequelize,
    modelName: 'Comment',
    tableName: 'comments',
    timestamps: true, // Tự động thêm createdAt và updatedAt
  }
);

module.exports = Comment;
