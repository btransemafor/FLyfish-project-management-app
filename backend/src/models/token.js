const { Model, DataTypes } = require("sequelize");
const sequelize = require("../config/db");

class Token extends Model {}

Token.init(
  {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
    },
    /*     userId: {
      type: DataTypes.UUID,
      allowNull: false,
    }, */
    token: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    /*     type: {
      type: DataTypes.ENUM("access", "refresh", "reset_password", "verify_email"),
      allowNull: false,
    }, */
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    isRevoked: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    replacedByToken: {
      // Lưu token mới nếu token này đã được rotate
      type: DataTypes.STRING,
      allowNull: true,
    },
    meta: {
      // thông tin phụ, ví dụ IP, thiết bị, user-agent
      type: DataTypes.JSONB,
      allowNull: true,
    },
  },
  {
    sequelize,
    modelName: "Token",
    tableName: "Tokens",
    timestamps: true,
  }
);

module.exports = Token;
