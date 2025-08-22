const { DataTypes, Model} = require('sequelize');
const sequelize = require('../config/db');


class User extends Model {}

User.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },  
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: { isEmail: true },
    },
    hash: {type: DataTypes.STRING},
    salt: { type: DataTypes.STRING },
    iterations:{ type: DataTypes.INTEGER }, 
    phone: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    avatar: {
      type: DataTypes.STRING, 
      allowNull: true, 
    }, 
    fullname: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    birthday: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    refreshToken: {
      type: DataTypes.STRING, 
      allowNull: true 
    }, 
    active: {
      type: DataTypes.BOOLEAN, 
      defaultValue: false
    }
  },
  {
    sequelize,
    modelName: 'User',
    tableName: 'users',
    timestamps: false,
  }
);

module.exports = User;