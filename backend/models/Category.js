// ملف: models/Category.js
// الغرض: تعريف نموذج الفئة لتنظيم المهام
// العلاقات:
// - Category ينتمي إلى User
// - Category يمتلك العديد من المهام Task
// التحقق:
// - color يجب أن يكون Hex صالح (مثل: #AABBCC)
// الدوال (Instance Methods):
// - getTasksCount(): عدد المهام في هذه الفئة
// - getCompletedTasksCount(): عدد المهام المكتملة في هذه الفئة

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
  }, // لون الفئة (Hex)
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

// الدوال - Methods
// getTasksCount(): حساب عدد المهام في هذه الفئة
Category.prototype.getTasksCount = async function() {
  const Task = require('./Task');
  return await Task.count({
    where: { categoryId: this.id }
  });
};

// getCompletedTasksCount(): حساب عدد المهام المكتملة في هذه الفئة
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
