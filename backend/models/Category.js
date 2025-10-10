const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Category = sequelize.define('Category', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id'
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    validate: {
      len: [1, 100]
    }
  },
  color: {
    type: DataTypes.STRING(7),
    defaultValue: '#3B82F6',
    validate: {
      is: /^#[0-9A-F]{6}$/i
    }
  },
  icon: {
    type: DataTypes.STRING(50),
    defaultValue: 'folder'
  },
  description: {
    type: DataTypes.TEXT
  },
  isDefault: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'is_default'
  }
}, {
  tableName: 'categories',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});

// Instance Methods
Category.prototype.getTasksCount = async function() {
  const Task = require('./Task');
  return await Task.count({
    where: { categoryId: this.id }
  });
};

Category.prototype.getCompletedTasksCount = async function() {
  const Task = require('./Task');
  return await Task.count({
    where: { 
      categoryId: this.id,
      status: 'completed'
    }
  });
};

module.exports = Category;
