// ملف: routes/users.js
// الغرض: إدارة ملف المستخدم (جلب وتحديث بيانات المستخدم)
// ملاحظة: يجب حماية هذه المسارات عبر Middleware للمصادقة ليكون req.user متاحاً

const express = require('express');
const { User } = require('../models');
const router = express.Router();

// Get user profile
// GET /profile
// الغرض: جلب بيانات المستخدم الحالي مع استبعاد الحقول الحساسة مثل passwordHash
router.get('/profile', async (req, res) => {
  try {
    const userId = req.user?.id;
    
    const user = await User.findByPk(userId, {
      attributes: { exclude: ['passwordHash'] }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'المستخدم غير موجود'
      });
    }

    res.json({
      success: true,
      data: { user }
    });

  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Update user profile
// PUT /profile
// الغرض: تحديث بيانات المستخدم (firstName, lastName, timezone, language, theme)
router.put('/profile', async (req, res) => {
  try {
    const userId = req.user?.id;
    const { firstName, lastName, timezone, language, theme } = req.body;

    const user = await User.findByPk(userId);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'المستخدم غير موجود'
      });
    }

    await user.update({
      firstName,
      lastName,
      timezone,
      language,
      theme
    });

    res.json({
      success: true,
      message: 'تم تحديث الملف الشخصي بنجاح',
      data: { user }
    });

  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

module.exports = router;
