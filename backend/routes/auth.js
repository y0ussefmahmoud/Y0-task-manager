const express = require('express');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const { User } = require('../models');
const router = express.Router();

// Register
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
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'بيانات غير صحيحة',
        errors: errors.array()
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

    // Generate JWT token
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

    // Update last activity
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
    console.error('Profile error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});

// Logout (for future use with refresh tokens)
router.post('/logout', (req, res) => {
  res.json({
    success: true,
    message: 'تم تسجيل الخروج بنجاح'
  });
});

module.exports = router;
