const { sequelize } = require('../config/database');

// Import Models
const User = require('./User');
const Task = require('./Task');
const Category = require('./Category');

// Define Associations
// User has many Tasks
User.hasMany(Task, {
  foreignKey: 'userId',
  as: 'tasks',
  onDelete: 'CASCADE'
});

Task.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user'
});

// User has many Categories
User.hasMany(Category, {
  foreignKey: 'userId',
  as: 'categories',
  onDelete: 'CASCADE'
});

Category.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user'
});

// Category has many Tasks
Category.hasMany(Task, {
  foreignKey: 'categoryId',
  as: 'tasks',
  onDelete: 'SET NULL'
});

Task.belongsTo(Category, {
  foreignKey: 'categoryId',
  as: 'category'
});

// Export models and sequelize
module.exports = {
  sequelize,
  User,
  Task,
  Category
};
