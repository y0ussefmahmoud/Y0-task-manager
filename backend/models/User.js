// ملف: models/User.js
// الغرض: تعريف نموذج المستخدم وإدارة نظام التحفيز (XP/Level/Streak)
// الحقول الرئيسية: معلومات الحساب، الإعدادات، التحفيز، حالة الحساب
// Hooks:
// - beforeCreate: تشفير كلمة المرور قبل إنشاء السجل
// - beforeUpdate: إعادة التشفير عند تغيير كلمة المرور
// الدوال (Instance Methods):
// - validatePassword(): مقارنة كلمة المرور مع الـ hash
// - getFullName(): دمج الاسم الأول والأخير
// - addXp(): إضافة نقاط XP وتحديث المستوى (كل 1000 XP = مستوى)
// - updateStreak(): تحديث عداد الأيام المتتالية بناءً على آخر نشاط
// - toJSON(): حذف passwordHash من الاستجابة لأسباب أمنية

const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const bcrypt = require('bcryptjs');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  username: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
    validate: {
      len: [3, 50],
      isAlphanumeric: true
    }
  }, // اسم المستخدم (فريد)
  email: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true
    }
  }, // البريد الإلكتروني (فريد)
  passwordHash: {
    type: DataTypes.STRING(255),
    allowNull: false,
    field: 'password_hash'
  }, // تشفير كلمة المرور
  firstName: {
    type: DataTypes.STRING(50),
    field: 'first_name'
  },
  lastName: {
    type: DataTypes.STRING(50),
    field: 'last_name'
  },
  avatarUrl: {
    type: DataTypes.STRING(255),
    field: 'avatar_url'
  },
  timezone: {
    type: DataTypes.STRING(50),
    defaultValue: 'UTC'
  },
  language: {
    type: DataTypes.STRING(10),
    defaultValue: 'ar'
  },
  theme: {
    type: DataTypes.STRING(20),
    defaultValue: 'light'
  },
  totalXp: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    field: 'total_xp'
  }, // إجمالي نقاط الخبرة (XP)
  level: {
    type: DataTypes.INTEGER,
    defaultValue: 1
  }, // المستوى الحالي (كل 1000 XP = مستوى)
  streakDays: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    field: 'streak_days'
  }, // عدد الأيام المتتالية
  lastActivity: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
    field: 'last_activity'
  }, // آخر وقت نشاط لتتبع الـ streak
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    field: 'is_active'
  },
  emailVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'email_verified'
  }
}, {
  tableName: 'users',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  hooks: {
    // تشفير كلمة المرور قبل الإنشاء
    beforeCreate: async (user) => {
      if (user.passwordHash) {
        user.passwordHash = await bcrypt.hash(user.passwordHash, 12);
      }
    },
    // إعادة التشفير إذا تغيرت كلمة المرور عند التحديث
    beforeUpdate: async (user) => {
      if (user.changed('passwordHash')) {
        user.passwordHash = await bcrypt.hash(user.passwordHash, 12);
      }
    }
  }
});

// Instance Methods
// validatePassword(): مقارنة كلمة المرور مع الـ hash المخزن
User.prototype.validatePassword = async function(password) {
  return await bcrypt.compare(password, this.passwordHash);
};

// getFullName(): إنشاء الاسم الكامل للمستخدم
User.prototype.getFullName = function() {
  return `${this.firstName || ''} ${this.lastName || ''}`.trim();
};

// addXp(): إضافة نقاط XP وحساب المستوى الجديد (كل 1000 XP = مستوى واحد)
User.prototype.addXp = async function(xp) {
  this.totalXp += xp;
  
  // Calculate new level (every 1000 XP = 1 level)
  const newLevel = Math.floor(this.totalXp / 1000) + 1;
  if (newLevel > this.level) {
    this.level = newLevel;
  }
  
  await this.save();
  return { totalXp: this.totalXp, level: this.level };
};

// updateStreak(): تحديث عداد الأيام المتتالية
// - إذا كان آخر نشاط بالأمس → استمرار وزيادة العداد
// - إذا كان قبل أكثر من يوم → إعادة العداد إلى 1
// - إذا كان اليوم نفسه → لا تغيير
User.prototype.updateStreak = async function() {
  const today = new Date();
  const lastActivity = new Date(this.lastActivity);
  
  // Check if last activity was yesterday
  const diffTime = Math.abs(today - lastActivity);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  
  if (diffDays === 1) {
    // Continue streak
    this.streakDays += 1;
  } else if (diffDays > 1) {
    // Reset streak
    this.streakDays = 1;
  }
  // If same day, don't change streak
  
  this.lastActivity = today;
  await this.save();
  return this.streakDays;
};

// toJSON(): إزالة passwordHash من الاستجابة لأسباب أمنية
User.prototype.toJSON = function() {
  const values = Object.assign({}, this.get());
  delete values.passwordHash;
  return values;
};

module.exports = User;
