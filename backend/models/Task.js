// ملف: models/Task.js
// الغرض: تعريف نموذج المهمة وإدارة خصائصها وعلاقاتها مع المستخدم والفئات
// الحقول الرئيسية: العنوان، الوصف، الأولوية، الحالة، التواريخ، مكافأة XP، التكرار، العلامات
// العلاقات:
// - Task ينتمي إلى User (مطلوب)
// - Task ينتمي إلى Category (اختياري)
// Hooks:
// - beforeUpdate: تعيين completedAt تلقائياً عند تغيير الحالة إلى completed

const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Task = sequelize.define('Task', {
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
  categoryId: {
    type: DataTypes.INTEGER,
    field: 'category_id'
  },
  title: {
    type: DataTypes.STRING(255),
    allowNull: false,
    validate: {
      len: [1, 255]
    }
  },
  description: {
    type: DataTypes.TEXT
  },
  priority: {
    type: DataTypes.ENUM('low', 'medium', 'high', 'urgent'),
    defaultValue: 'medium'
  }, // ENUM: ترتيب الأولوية (low/medium/high/urgent)
  status: {
    type: DataTypes.ENUM('pending', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'pending'
  }, // ENUM: حالة المهمة (pending/in_progress/completed/cancelled)
  dueDate: {
    type: DataTypes.DATE,
    field: 'due_date'
  },
  reminderDate: {
    type: DataTypes.DATE,
    field: 'reminder_date'
  },
  estimatedDuration: {
    type: DataTypes.INTEGER, // in minutes
    field: 'estimated_duration'
  }, // مدة التنفيذ المقدرة بالدقائق
  actualDuration: {
    type: DataTypes.INTEGER, // in minutes
    field: 'actual_duration'
  }, // مدة التنفيذ الفعلية بالدقائق
  xpReward: {
    type: DataTypes.INTEGER,
    defaultValue: 10,
    field: 'xp_reward'
  },
  isRecurring: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'is_recurring'
  }, // تكرار المهمة
  recurringPattern: {
    type: DataTypes.STRING(50),
    field: 'recurring_pattern'
  }, // نمط التكرار (مثال: daily/weekly)
  tags: {
    type: DataTypes.JSON,
    defaultValue: []
  },
  attachments: {
    type: DataTypes.JSON,
    defaultValue: []
  },
  completedAt: {
    type: DataTypes.DATE,
    field: 'completed_at'
  }
}, {
  tableName: 'tasks',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at',
  hooks: {
    // عند تحديث الحالة إلى "completed" لأول مرة، يتم تعيين تاريخ الإكمال
    beforeUpdate: (task) => {
      if (task.changed('status') && task.status === 'completed' && !task.completedAt) {
        task.completedAt = new Date();
      }
    }
  }
});

// Instance Methods
// markCompleted(): تحديد المهمة كمكتملة وتعيين وقت الإكمال
Task.prototype.markCompleted = async function() {
  this.status = 'completed';
  this.completedAt = new Date();
  await this.save();
  return this;
};

// isOverdue(): التحقق من تأخر المهمة (إن كان dueDate في الماضي والحالة ليست مكتملة)
Task.prototype.isOverdue = function() {
  if (!this.dueDate || this.status === 'completed') return false;
  return new Date() > new Date(this.dueDate);
};

// getDaysUntilDue(): حساب عدد الأيام المتبقية حتى تاريخ الاستحقاق (أو null إن لم يكن محدداً)
Task.prototype.getDaysUntilDue = function() {
  if (!this.dueDate) return null;
  const today = new Date();
  const due = new Date(this.dueDate);
  const diffTime = due - today;
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
};

// getPriorityScore(): تحويل الأولوية إلى رقم للمقارنة (urgent=4, high=3, medium=2, low=1)
Task.prototype.getPriorityScore = function() {
  const priorityScores = {
    low: 1,
    medium: 2,
    high: 3,
    urgent: 4
  };
  return priorityScores[this.priority] || 2;
};

// calculateXpReward(): حساب مكافأة XP بناءً على الأولوية والمدة المقدرة والتأخير
// الصيغة: baseXp + priorityBonus + durationBonus - overduePenalty (الحد الأدنى 5 XP)
Task.prototype.calculateXpReward = function() {
  let baseXp = 10;
  
  // Priority bonus
  const priorityBonus = {
    low: 0,
    medium: 5,
    high: 10,
    urgent: 20
  };
  
  // Duration bonus (for longer tasks)
  const durationBonus = this.estimatedDuration ? Math.floor(this.estimatedDuration / 30) * 5 : 0;
  
  // Overdue penalty
  const overduePenalty = this.isOverdue() ? -5 : 0;
  
  this.xpReward = Math.max(baseXp + priorityBonus[this.priority] + durationBonus + overduePenalty, 5);
  return this.xpReward;
};

module.exports = Task;
