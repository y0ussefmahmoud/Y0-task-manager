// ملف: routes/categories.js
// الغرض: إدارة الفئات (إنشاء/قراءة/تحديث/حذف) الخاصة بالمستخدم
// العلاقة: الفئة Category قد تحتوي عدة مهام Task وترتبط بمستخدم واحد User
// التحقق: استخدام express-validator للتحقق من صحة الاسم واللون (Hex)

const express = require('express');
const { body, validationResult } = require('express-validator');
const { Category } = require('../models');
const router = express.Router();

// Get all categories for user
// GET /
// الغرض: جلب جميع فئات المستخدم مرتبة أبجدياً
router.get('/', async (req, res) => {
  try {
    const userId = req.user?.id;

    const categories = await Category.findAll({
      where: { userId },
      order: [['name', 'ASC']]
    });

    res.json({
      success: true,
      data: { categories }
    });

  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Create new category
// POST /
// الغرض: إنشاء فئة جديدة بعد التحقق من صحة البيانات وعدم تكرار الاسم
// ملاحظة: يتم تعيين قيم افتراضية للون والأيقونة إن لم تُرسل
router.post('/', [
  body('name')
    .notEmpty()
    .withMessage('اسم الفئة مطلوب')
    .isLength({ max: 100 })
    .withMessage('اسم الفئة لا يجب أن يتجاوز 100 حرف'),
  body('color')
    .optional()
    .matches(/^#[0-9A-F]{6}$/i)
    .withMessage('لون الفئة غير صحيح'),
  body('icon')
    .optional()
    .isLength({ max: 50 })
    .withMessage('أيقونة الفئة لا يجب أن تتجاوز 50 حرف')
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
    const { name, color, icon, description } = req.body;

    const category = await Category.create({
      userId,
      name,
      color: color || '#3B82F6',
      icon: icon || 'folder',
      description
    });

    res.status(201).json({
      success: true,
      message: 'تم إنشاء الفئة بنجاح',
      data: { category }
    });

  } catch (error) {
    console.error('Create category error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Update category
// PUT /:id
// الغرض: تحديث بيانات الفئة مع التحقق من صحة المدخلات
router.put('/:id', [
  body('name')
    .optional()
    .notEmpty()
    .withMessage('اسم الفئة لا يمكن أن يكون فارغ')
    .isLength({ max: 100 })
    .withMessage('اسم الفئة لا يجب أن يتجاوز 100 حرف'),
  body('color')
    .optional()
    .matches(/^#[0-9A-F]{6}$/i)
    .withMessage('لون الفئة غير صحيح')
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
    const categoryId = req.params.id;

    const category = await Category.findOne({
      where: { id: categoryId, userId }
    });

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'الفئة غير موجودة'
      });
    }

    const updatedCategory = await category.update(req.body);

    res.json({
      success: true,
      message: 'تم تحديث الفئة بنجاح',
      data: { category: updatedCategory }
    });

  } catch (error) {
    console.error('Update category error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Delete category
// DELETE /:id
// الغرض: حذف فئة تخص المستخدم الحالي
router.delete('/:id', async (req, res) => {
  try {
    const userId = req.user?.id;
    const categoryId = req.params.id;

    const category = await Category.findOne({
      where: { id: categoryId, userId }
    });

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'الفئة غير موجودة'
      });
    }

    await category.destroy();

    res.json({
      success: true,
      message: 'تم حذف الفئة بنجاح'
    });

  } catch (error) {
    console.error('Delete category error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

module.exports = router;
