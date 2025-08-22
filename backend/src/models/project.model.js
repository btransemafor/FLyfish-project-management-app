const sequelize = require('../config/db'); 
const {DataTypes,Model, ENUM, DATE} = require('sequelize'); 
class Project extends Model {}
Project.init({
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    }, 
    name: {
        type: DataTypes.STRING,
        allowNull: false,
    }, 
    description: {
        type: DataTypes.STRING, 
        allowNull: true,
    }, 
    status: {
        type: DataTypes.ENUM('OnGoing', 'Completed'), 
        defaultValue: 'OnGoing'
    }, 

    startDate: {
        type: DataTypes.DATE, 
        defaultValue: DataTypes.NOW, 
        allowNull: false, 
    }, 

    endDate: {
        type: DataTypes.DATE, 
        allowNull: true 
    }
}, {sequelize, 
    modelName: 'Project', 
    tableName: 'projects', 
    timestamps: true
})

module.exports = Project; 