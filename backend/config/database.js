// ملف: config/database.js
// الغرض: إعداد اتصال قاعدة البيانات MySQL باستخدام Sequelize ORM
// الإعدادات:
// - host, port, database, username, password, dialect: معلمات الاتصال بقاعدة البيانات
// - pool: إعدادات التجمع (Pooling) لتحسين الأداء (max/min/acquire/idle)
// - timezone: تضبيط المنطقة الزمنية (+03:00 للقاهرة)
// - define: تعاريف عامة للجداول (charset/collate لدعم العربية بشكل كامل)
// الدوال:
// - testConnection(): اختبار الاتصال والتحقق من الصحة
// - initDatabase(): تهيئة الاتصال ومزامنة النماذج في وضع التطوير

const { Sequelize } = require('sequelize');
require('dotenv').config();

// Database Configuration
const sequelize = new Sequelize({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  database: process.env.DB_NAME || 'y0_task_manager',
  username: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  dialect: 'mysql',
  logging: process.env.NODE_ENV === 'development' ? console.log : false,
  pool: {
    max: 10, // أقصى عدد للاتصالات المفتوحة
    min: 0,  // أقل عدد للاتصالات
    acquire: 30000, // مدة الانتظار قبل الفشل في الحصول على اتصال (ms)
    idle: 10000 // مدة إبقاء الاتصال خاملاً قبل إغلاقه (ms)
  },
  timezone: '+03:00', // Cairo timezone
  define: {
    charset: 'utf8mb4', // دعم الرموز التعبيرية والعربية
    collate: 'utf8mb4_unicode_ci',
    timestamps: true,
    underscored: false,
    freezeTableName: true
  }
});

// Test Database Connection
// الغرض: التأكد من إمكانية الاتصال بقاعدة البيانات وعرض رسالة مناسبة
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connection established successfully');
  } catch (error) {
    console.error('❌ Unable to connect to database:', error.message);
    process.exit(1);
  }
};

// Initialize Database
// الغرض: تهيئة قاعدة البيانات واستدعاء المزامنة في وضع التطوير فقط
const initDatabase = async () => {
  try {
    await testConnection();
    
    // Sync models (create tables if they don't exist)
    if (process.env.NODE_ENV === 'development') {
      await sequelize.sync({ alter: true });
      console.log('✅ Database synchronized successfully');
    }
  } catch (error) {
    console.error('❌ Database initialization failed:', error.message);
    process.exit(1);
  }
};

module.exports = {
  sequelize,
  testConnection,
  initDatabase
};
