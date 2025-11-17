// ملف: models/index.js
// الغرض: تجميع جميع النماذج وتعريف العلاقات بينها عبر Sequelize
// الأهمية: هذا الملف يربط النماذج ببعضها لتفعيل القيود والعلاقات في قاعدة البيانات

const { sequelize } = require('../config/database');

// Import Models
const User = require('./User');
const Task = require('./Task');
const Category = require('./Category');

// Define Associations
// User has many Tasks: المستخدم يمتلك عدة مهام، وعند حذف المستخدم تُحذف مهامه (CASCADE)
User.hasMany(Task, {
  foreignKey: 'userId',
  as: 'tasks',
  onDelete: 'CASCADE'
});

// Task belongs to User: كل مهمة تنتمي لمستخدم واحد
Task.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user'
});

// User has many Categories: المستخدم يمتلك عدة فئات، وعند حذف المستخدم تُحذف فئاته (CASCADE)
User.hasMany(Category, {
  foreignKey: 'userId',
  as: 'categories',
  onDelete: 'CASCADE'
});

// Category belongs to User: كل فئة تنتمي لمستخدم واحد
Category.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user'
});

// Category has many Tasks: الفئة تحتوي على عدة مهام، وعند حذف الفئة تُعيّن فئة المهمة إلى NULL (SET NULL)
Category.hasMany(Task, {
  foreignKey: 'categoryId',
  as: 'tasks',
  onDelete: 'SET NULL'
});

// Task belongs to Category: كل مهمة قد تنتمي لفئة (اختياري)
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
