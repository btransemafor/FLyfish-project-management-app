/* // Notification (thông báo chung)
const Notification = sequelize.define('Notification', {
  id: { type: DataTypes.UUID, primaryKey: true, defaultValue: DataTypes.UUIDV4 },
  title: DataTypes.STRING,
  message: DataTypes.TEXT,
  type: DataTypes.STRING,
  relatedId: DataTypes.UUID,
  priority: DataTypes.ENUM('low', 'medium', 'high'),
  deliveryMethod: DataTypes.JSONB,
}, { timestamps: true });

// NotificationRecipient (người nhận thông báo)
const NotificationRecipient = sequelize.define('NotificationRecipient', {
  id: { type: DataTypes.UUID, primaryKey: true, defaultValue: DataTypes.UUIDV4 },
  notificationId: {
    type: DataTypes.UUID,
    references: {
      model: Notification,
      key: 'id'
    },
    onDelete: 'CASCADE'
  },
  userId: { type: DataTypes.UUID, allowNull: false },
  isRead: { type: DataTypes.BOOLEAN, defaultValue: false },
}, { timestamps: true });

// Associations
Notification.hasMany(NotificationRecipient, { foreignKey: 'notificationId', as: 'recipients' });
NotificationRecipient.belongsTo(Notification, { foreignKey: 'notificationId' });
 */

const { Model, DataTypes } = require("sequelize");
const sequelize = require("../config/db");

class Notification extends Model {}
Notification.init(
  {
    id: {
      type: DataTypes.UUID,
      primaryKey: true,
      defaultValue: DataTypes.UUIDV4,
    },

    title: DataTypes.STRING,
    message: DataTypes.TEXT,
    type: DataTypes.STRING,
    relatedId: DataTypes.UUID,
    priority: DataTypes.ENUM("low", "medium", "high"),
    deliveryMethod: DataTypes.JSONB,
  },
  {
    sequelize,
    modelName: "Notification",
    tableName: "Notifications",
    timestamps: true,
  }
);

module.exports = Notification; 
