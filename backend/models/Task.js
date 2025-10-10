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
  },
  status: {
    type: DataTypes.ENUM('pending', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'pending'
  },
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
  },
  actualDuration: {
    type: DataTypes.INTEGER, // in minutes
    field: 'actual_duration'
  },
  xpReward: {
    type: DataTypes.INTEGER,
    defaultValue: 10,
    field: 'xp_reward'
  },
  isRecurring: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'is_recurring'
  },
  recurringPattern: {
    type: DataTypes.STRING(50),
    field: 'recurring_pattern'
  },
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
    beforeUpdate: (task) => {
      if (task.changed('status') && task.status === 'completed' && !task.completedAt) {
        task.completedAt = new Date();
      }
    }
  }
});

// Instance Methods
Task.prototype.markCompleted = async function() {
  this.status = 'completed';
  this.completedAt = new Date();
  await this.save();
  return this;
};

Task.prototype.isOverdue = function() {
  if (!this.dueDate || this.status === 'completed') return false;
  return new Date() > new Date(this.dueDate);
};

Task.prototype.getDaysUntilDue = function() {
  if (!this.dueDate) return null;
  const today = new Date();
  const due = new Date(this.dueDate);
  const diffTime = due - today;
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
};

Task.prototype.getPriorityScore = function() {
  const priorityScores = {
    low: 1,
    medium: 2,
    high: 3,
    urgent: 4
  };
  return priorityScores[this.priority] || 2;
};

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
