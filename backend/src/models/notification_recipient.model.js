// NotificationRecipient (người nhận thông báo)
const { Model, DataTypes } = require("sequelize");
const sequelize = require("../config/db");


class NotificationRecipient extends Model {}
NotificationRecipient.init({
    id: { type: DataTypes.UUID, primaryKey: true, defaultValue: DataTypes.UUIDV4 },
  userId: { type: DataTypes.UUID, allowNull: false },
  isRead: { type: DataTypes.BOOLEAN, defaultValue: false },
}
,
{
    sequelize,
    modelName: "NotificationRecipient",
    tableName: "NotificationRecipients",
    timestamps: true,
}
); 
module.exports = NotificationRecipient; 
