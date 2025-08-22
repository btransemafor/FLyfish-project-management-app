const { Model, DataTypes } = require('sequelize');
const sequelize = require('../config/db');

class Attachment extends Model {}

Attachment.init({
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,  // Hoặc UUIDV1 nếu bạn muốn timestamp-based UUID
    primaryKey: true,
  },
  file_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  file_url: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  upload_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },

  is_main: {
    type: DataTypes.BOOLEAN, 
    defaultValue: false
  }
}, {
  sequelize,            
  modelName: 'Attachment',
  tableName: 'attachments',  
  timestamps: false,     
});

module.exports = Attachment;
