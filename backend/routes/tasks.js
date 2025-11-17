// ملف: routes/tasks.js
// الغرض: إدارة مهام المستخدم (إنشاء، قراءة، تحديث، حذف) بالإضافة إلى الإحصائيات
// العلاقات:
// - Task يرتبط بـ User (belongsTo)
// - Task يرتبط بـ Category اختيارياً (belongsTo)
// الأدوات:
// - express-validator للتحقق من المدخلات
// - Sequelize للنماذج والاستعلامات

const express = require('express');
const { body, validationResult, query } = require('express-validator');
const { Task, Category, User } = require('../models');
const router = express.Router();

// Get all tasks for user
// GET /
// الغرض: جلب قائمة المهام مع دعم الفلترة والترتيب والصفحات (pagination)
// معلمات الاستعلام:
// - status, priority, categoryId للفلترة
// - page, limit للتحكم في صفحات النتائج
router.get('/', [
  query('status').optional().isIn(['pending', 'in_progress', 'completed', 'cancelled']),
  query('priority').optional().isIn(['low', 'medium', 'high', 'urgent']),
  query('categoryId').optional().isInt(),
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 })
], async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'غير مصرح'
      });
    }

    const { status, priority, categoryId, page = 1, limit = 20 } = req.query;
    
    // بناء شروط البحث ديناميكياً حسب المعلمات
    const where = { userId };
    if (status) where.status = status;
    if (priority) where.priority = priority;
    if (categoryId) where.categoryId = categoryId;

    // الحساب للصفحات: offset = (page - 1) * limit
    const offset = (page - 1) * limit;

    const { count, rows: tasks } = await Task.findAndCountAll({
      where,
      include: [
        {
          model: Category,
          as: 'category',
          attributes: ['id', 'name', 'color', 'icon']
        }
      ],
      // ترتيب افتراضي: الأعلى أولوية أولاً، ثم أقرب موعد، ثم الأحدث إنشاءً
      order: [
        ['priority', 'DESC'],
        ['dueDate', 'ASC'],
        ['createdAt', 'DESC']
      ],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      success: true,
      data: {
        tasks,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(count / limit)
        }
      }
    });

  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Get single task
// GET /:id
// الغرض: جلب مهمة واحدة مع بيانات الفئة التابعة لها
router.get('/:id', async (req, res) => {
  try {
    const userId = req.user?.id;
    const taskId = req.params.id;

    const task = await Task.findOne({
      where: { id: taskId, userId },
      include: [
        {
          model: Category,
          as: 'category',
          attributes: ['id', 'name', 'color', 'icon']
        }
      ]
    });

    if (!task) {
      return res.status(404).json({
        success: false,
        message: 'المهمة غير موجودة'
      });
    }

    res.json({
      success: true,
      data: { task }
    });

  } catch (error) {
    console.error('Get task error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Create new task
// POST /
// الغرض: إنشاء مهمة جديدة بعد التحقق من صحة البيانات والتحقق من ملكية الفئة
// منطق إضافي: حساب مكافأة XP للمهمة عبر calculateXpReward()
router.post('/', [
  body('title')
    .notEmpty()
    .withMessage('عنوان المهمة مطلوب')
    .isLength({ max: 255 })
    .withMessage('عنوان المهمة لا يجب أن يتجاوز 255 حرف'),
  body('description')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('وصف المهمة لا يجب أن يتجاوز 1000 حرف'),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high', 'urgent'])
    .withMessage('أولوية المهمة غير صحيحة'),
  body('categoryId')
    .optional()
    .isInt()
    .withMessage('معرف الفئة يجب أن يكون رقم'),
  body('dueDate')
    .optional()
    .isISO8601()
    .withMessage('تاريخ الاستحقاق غير صحيح'),
  body('estimatedDuration')
    .optional()
    .isInt({ min: 1 })
    .withMessage('المدة المقدرة يجب أن تكون رقم موجب')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'بيانات غير صحيحة',
        errors: errors.array()
      });
    }

    const userId = req.user?.id;
    const { title, description, priority, categoryId, dueDate, estimatedDuration, tags } = req.body;

    // التحقق من أن الفئة (إن تم تمريرها) تخص نفس المستخدم
    if (categoryId) {
      const category = await Category.findOne({
        where: { id: categoryId, userId }
      });
      
      if (!category) {
        return res.status(400).json({
          success: false,
          message: 'الفئة غير موجودة'
        });
      }
    }

    const task = await Task.create({
      userId,
      title,
      description,
      priority: priority || 'medium',
      categoryId,
      dueDate,
      estimatedDuration,
      tags: tags || []
    });

    // حساب مكافأة XP للمهمة بناءً على الأولوية والمدة والتأخير
    task.calculateXpReward();
    await task.save();

    // Load task with category
    const taskWithCategory = await Task.findByPk(task.id, {
      include: [
        {
          model: Category,
          as: 'category',
          attributes: ['id', 'name', 'color', 'icon']
        }
      ]
    });

    res.status(201).json({
      success: true,
      message: 'تم إنشاء المهمة بنجاح',
      data: { task: taskWithCategory }
    });

  } catch (error) {
    console.error('Create task error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Update task
// PUT /:id
// الغرض: تحديث خصائص المهمة. وعند اكتمالها لأول مرة يتم منح XP للمستخدم وتحديث الـ streak
router.put('/:id', [
  body('title')
    .optional()
    .notEmpty()
    .withMessage('عنوان المهمة لا يمكن أن يكون فارغ')
    .isLength({ max: 255 })
    .withMessage('عنوان المهمة لا يجب أن يتجاوز 255 حرف'),
  body('status')
    .optional()
    .isIn(['pending', 'in_progress', 'completed', 'cancelled'])
    .withMessage('حالة المهمة غير صحيحة'),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high', 'urgent'])
    .withMessage('أولوية المهمة غير صحيحة')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'بيانات غير صحيحة',
        errors: errors.array()
      });
    }

    const userId = req.user?.id;
    const taskId = req.params.id;

    const task = await Task.findOne({
      where: { id: taskId, userId }
    });

    if (!task) {
      return res.status(404).json({
        success: false,
        message: 'المهمة غير موجودة'
      });
    }

    // تحديث بيانات المهمة
    const updatedTask = await task.update(req.body);

    // في حال تغيرت الحالة إلى مكتملة لأول مرة: امنح نقاط XP وحدث سلسلة الأيام
    if (updatedTask.status === 'completed' && task.status !== 'completed') {
      const user = await User.findByPk(userId);
      await user.addXp(updatedTask.xpReward);
      await user.updateStreak();
    }

    // Load task with category
    const taskWithCategory = await Task.findByPk(updatedTask.id, {
      include: [
        {
          model: Category,
          as: 'category',
          attributes: ['id', 'name', 'color', 'icon']
        }
      ]
    });

    res.json({
      success: true,
      message: 'تم تحديث المهمة بنجاح',
      data: { task: taskWithCategory }
    });

  } catch (error) {
    console.error('Update task error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Delete task
// DELETE /:id
// الغرض: حذف مهمة تخص المستخدم الحالي
router.delete('/:id', async (req, res) => {
  try {
    const userId = req.user?.id;
    const taskId = req.params.id;

    const task = await Task.findOne({
      where: { id: taskId, userId }
    });

    if (!task) {
      return res.status(404).json({
        success: false,
        message: 'المهمة غير موجودة'
      });
    }

    await task.destroy();

    res.json({
      success: true,
      message: 'تم حذف المهمة بنجاح'
    });

  } catch (error) {
    console.error('Delete task error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Get tasks statistics
// GET /stats/overview
// الغرض: حساب نظرة عامة لإحصائيات المهام حسب الحالة (معلقة/قيد التنفيذ/مكتملة/ملغاة)
router.get('/stats/overview', async (req, res) => {
  try {
    const userId = req.user?.id;

    // استخدام دالة COUNT للتجميع حسب الحالة وإرجاع نتائج خام
    const stats = await Task.findAll({
      where: { userId },
      attributes: [
        'status',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['status'],
      raw: true
    });

    const overview = {
      total: 0,
      pending: 0,
      inProgress: 0,
      completed: 0,
      cancelled: 0
    };

    stats.forEach(stat => {
      overview.total += parseInt(stat.count);
      switch (stat.status) {
        case 'pending':
          overview.pending = parseInt(stat.count);
          break;
        case 'in_progress':
          overview.inProgress = parseInt(stat.count);
          break;
        case 'completed':
          overview.completed = parseInt(stat.count);
          break;
        case 'cancelled':
          overview.cancelled = parseInt(stat.count);
          break;
      }
    });

    res.json({
      success: true,
      data: { overview }
    });

  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

module.exports = router;
