# 🚀 التثبيت والإعداد

## 📋 المتطلبات الأساسية

قبل البدء، تأكد من تثبيت:

### 🖥️ البرامج المطلوبة
- **Node.js 18+** - [تحميل](https://nodejs.org/)
- **Flutter 3.0+** - [تحميل](https://flutter.dev/docs/get-started/install)
- **Docker Desktop** - [تحميل](https://www.docker.com/products/docker-desktop)
- **Git** - [تحميل](https://git-scm.com/downloads)

### 🔍 التحقق من التثبيت
```bash
# التحقق من Node.js
node --version  # يجب أن يكون 18.0.0 أو أحدث

# التحقق من Flutter
flutter --version  # يجب أن يكون 3.0.0 أو أحدث

# التحقق من Docker
docker --version

# التحقق من Git
git --version
```

## 📥 تحميل المشروع

### الطريقة الأولى: Git Clone
```bash
git clone https://github.com/yourusername/y0-task-manager.git
cd y0-task-manager
```

### الطريقة الثانية: تحميل ZIP
1. اذهب إلى [صفحة المشروع](https://github.com/yourusername/y0-task-manager)
2. اضغط على **Code** → **Download ZIP**
3. استخرج الملفات في مجلد جديد

## ⚡ التشغيل السريع

### Windows
```batch
# تشغيل التطبيق كاملاً
start-app.bat
```

### Linux/Mac
```bash
# إعطاء صلاحيات التنفيذ
chmod +x start-app.sh

# تشغيل التطبيق
./start-app.sh
```

## 🔧 الإعداد اليدوي

إذا كنت تفضل الإعداد اليدوي:

### 1. إعداد قاعدة البيانات
```bash
# تشغيل Docker containers
docker-compose up -d

# انتظار تحميل قاعدة البيانات (30 ثانية)
```

### 2. إعداد Backend
```bash
cd backend

# تثبيت المكتبات
npm install

# إنشاء ملف البيئة
cp .env.example .env

# تحرير متغيرات البيئة (اختياري)
# nano .env

# تشغيل الخادم
npm run dev
```

### 3. إعداد Frontend
```bash
# في terminal جديد
cd frontend

# تثبيت المكتبات
flutter pub get

# إنشاء ملفات Hive
flutter packages pub run build_runner build

# تشغيل التطبيق
flutter run -d chrome --web-port=3000
```

## 🌐 الوصول للتطبيق

بعد التشغيل الناجح:

| الخدمة | الرابط | الوصف |
|--------|---------|--------|
| 🖥️ **التطبيق الرئيسي** | [http://localhost:3000](http://localhost:3000) | واجهة المستخدم |
| 🔌 **API Backend** | [http://localhost:3001/api](http://localhost:3001/api) | خادم API |
| 🗄️ **قاعدة البيانات** | [http://localhost:8080](http://localhost:8080) | phpMyAdmin |

## 👤 بيانات الاختبار

للتجربة السريعة:
```
📧 Email: demo@y0.com
🔒 Password: password
```

## 🛠️ إعدادات متقدمة

### تخصيص متغيرات البيئة
```bash
# في ملف backend/.env
NODE_ENV=development
PORT=3001
FRONTEND_URL=http://localhost:3000

# قاعدة البيانات
DB_HOST=localhost
DB_PORT=3306
DB_NAME=y0_task_manager
DB_USER=y0user
DB_PASSWORD=y0password

# JWT
JWT_SECRET=your_secret_key_here
JWT_EXPIRES_IN=7d
```

### إعداد قاعدة بيانات خارجية
```bash
# تحديث متغيرات قاعدة البيانات
DB_HOST=your_mysql_host
DB_PORT=3306
DB_NAME=your_database_name
DB_USER=your_username
DB_PASSWORD=your_password
```

## 🐛 حل المشاكل الشائعة

### مشكلة: Port مستخدم
```bash
# إيقاف العمليات المستخدمة للـ ports
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:3000 | xargs kill -9
```

### مشكلة: Docker لا يعمل
```bash
# تأكد من تشغيل Docker Desktop
# إعادة تشغيل Docker
docker-compose down
docker-compose up -d
```

### مشكلة: Flutter dependencies
```bash
cd frontend
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build
```

### مشكلة: Node.js dependencies
```bash
cd backend
rm -rf node_modules package-lock.json
npm install
```

## ✅ التحقق من التثبيت

### اختبار Backend
```bash
curl http://localhost:3001/api/health
# يجب أن يرجع: {"status": "OK"}
```

### اختبار Frontend
افتح [http://localhost:3000](http://localhost:3000) في المتصفح

### اختبار قاعدة البيانات
افتح [http://localhost:8080](http://localhost:8080) وسجل دخول بـ:
- **Username**: root
- **Password**: rootpassword

## 🔄 التحديث

### تحديث المشروع
```bash
git pull origin main
npm run setup
```

### تحديث المكتبات
```bash
# Backend
cd backend && npm update

# Frontend
cd frontend && flutter pub upgrade
```

## 📞 الدعم

إذا واجهت مشاكل في التثبيت:
- 📧 [فتح issue جديد](https://github.com/yourusername/y0-task-manager/issues)
- 💬 [مناقشة في المجتمع](https://github.com/yourusername/y0-task-manager/discussions)
- 📖 [مراجعة المشاكل الشائعة](Common-Issues)

---

**🎉 مبروك! التطبيق جاهز للاستخدام**
