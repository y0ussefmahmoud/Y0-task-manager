// ملف: routes/auth.js
// الغرض: تعريف مسارات المصادقة والتسجيل للمستخدمين
// التقنيات المستخدمة:
// - express: إطار العمل لمعالجة الطلبات HTTP
// - jsonwebtoken (JWT): لتوليد رموز الوصول والتحقق من هوية المستخدم
// - express-validator: للتحقق من صحة البيانات المدخلة من العميل
// - User model: للتعامل مع بيانات المستخدمين في قاعدة البيانات
//
// ملاحظات مهمة:
// - يتم استخدام express-validator للتحقق من حقول الطلب وإرجاع رسائل عربية واضحة عند وجود أخطاء
// - يتم توليد JWT مع payload يحتوي userId و email ومدة صلاحية من متغيرات البيئة
// - المسارات الحالية لا تستخدم Middleware للتوثيق؛ يفترض وجوده مستقبلاً لحماية المسارات الحساسة

const express = require('express');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { User } = require('../models');
const router = express.Router();

// Register
// POST /register
// الغرض: إنشاء حساب مستخدم جديد
// الخطوات:
// 1) التحقق من صحة البيانات باستخدام express-validator
// 2) التأكد من عدم وجود مستخدم بنفس البريد/اسم المستخدم
// 3) إنشاء المستخدم (يتم تشفير كلمة المرور في hook قبل الحفظ)
// 4) توليد JWT token مع مدة صلاحية محددة
// 5) إعادة بيانات المستخدم مع الرمز
router.post('/register', [
  body('username')
    .isLength({ min: 3, max: 50 })
    .withMessage('اسم المستخدم يجب أن يكون بين 3 و 50 حرف')
    .isAlphanumeric()
    .withMessage('اسم المستخدم يجب أن يحتوي على أحرف وأرقام فقط'),
  body('email')
    .isEmail()
    .withMessage('البريد الإلكتروني غير صحيح')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 6 })
    .withMessage('كلمة المرور يجب أن تكون 6 أحرف على الأقل'),
  body('firstName')
    .optional()
    .isLength({ max: 50 })
    .withMessage('الاسم الأول لا يجب أن يتجاوز 50 حرف'),
  body('lastName')
    .optional()
    .isLength({ max: 50 })
    .withMessage('الاسم الأخير لا يجب أن يتجاوز 50 حرف')
], async (req, res) => {
  try {
    // Check validation errors
    // التحقق من الأخطاء الناتجة عن express-validator
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'بيانات غير صحيحة',
        errors: errors.array() // إرجاع قائمة الأخطاء مع الرسائل العربية
      });
    }

    const { username, email, password, firstName, lastName } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({
      where: {
        $or: [{ email }, { username }]
      }
    });

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'المستخدم موجود بالفعل'
      });
    }

    // Create new user
    const user = await User.create({
      username,
      email,
      passwordHash: password,
      firstName,
      lastName
    });

    // توليد رمز JWT
    // - payload: userId, email
    // - السر: JWT_SECRET من متغيرات البيئة
    // - مدة الصلاحية: JWT_EXPIRES_IN أو 7 أيام افتراضياً
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.status(201).json({
      success: true,
      message: 'تم إنشاء الحساب بنجاح',
      data: {
        user,
        token
      }
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Login
// POST /login
// الغرض: تسجيل دخول المستخدم والتحقق من البريد/كلمة المرور
// الخطوات:
// 1) التحقق من صحة الحقول
// 2) البحث عن المستخدم بواسطة البريد والتأكد أنه نشط
// 3) التحقق من كلمة المرور عبر User.validatePassword()
// 4) تحديث lastActivity
// 5) توليد JWT وإعادة البيانات
router.post('/login', [
  body('email')
    .isEmail()
    .withMessage('البريد الإلكتروني غير صحيح')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('كلمة المرور مطلوبة')
], async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'بيانات غير صحيحة',
        errors: errors.array()
      });
    }

    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({
      where: { email, isActive: true }
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
      });
    }

    // Validate password
    const isValidPassword = await user.validatePassword(password);
    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
      });
    }

    // تحديث آخر نشاط للمستخدم لتعقب الـ streak لاحقاً
    user.lastActivity = new Date();
    await user.save();

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.json({
      success: true,
      message: 'تم تسجيل الدخول بنجاح',
      data: {
        user,
        token
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Get Profile
// GET /profile
// الغرض: جلب بيانات المستخدم الحالي بناءً على الرمز (JWT)
// ملاحظة: يفترض وجود Middleware يملأ req.user من الرمز
router.get('/profile', async (req, res) => {
  try {
    // This route will be protected by auth middleware
    const userId = req.user?.id;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'غير مصرح'
      });
    }

    const user = await User.findByPk(userId);
    
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
    // معالجة الأخطاء العامة وإرجاع رسالة عربية مناسبة
    console.error('Profile error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Logout
// POST /logout
// الغرض: تسجيل الخروج (نقطة نهاية تمهيدية؛ قد تُستخدم مع Refresh Tokens مستقبلاً)
router.post('/logout', (req, res) => {
  res.json({
    success: true,
    message: 'تم تسجيل الخروج بنجاح'
  });
});

module.exports = router;
