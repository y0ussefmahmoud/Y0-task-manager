# المساهمة في Y0 Task Manager

نرحب بمساهماتكم في تطوير Y0 Task Manager! 🎉

## كيفية المساهمة

### 1. إعداد البيئة المحلية

```bash
# استنساخ المشروع
git clone https://github.com/yourusername/y0-task-manager.git
cd y0-task-manager

# تشغيل التطبيق
./start-app.bat  # Windows
# أو
chmod +x start-app.sh && ./start-app.sh  # Linux/Mac
```

### 2. هيكل المشروع

```
y0-task-manager/
├── backend/          # Node.js API
├── frontend/         # Flutter App
├── database/         # MySQL Schema
└── docs/            # التوثيق
```

### 3. معايير الكود

#### Backend (Node.js):
- استخدم ES6+ syntax
- اتبع معايير ESLint
- اكتب تعليقات باللغة العربية
- استخدم async/await بدلاً من callbacks

#### Frontend (Flutter):
- اتبع Flutter style guide
- استخدم Provider للـ state management
- اكتب widgets قابلة لإعادة الاستخدام
- اتبع Material Design guidelines

### 4. إرسال Pull Request

1. Fork المشروع
2. أنشئ branch جديد (`git checkout -b feature/amazing-feature`)
3. Commit التغييرات (`git commit -m 'Add amazing feature'`)
4. Push للـ branch (`git push origin feature/amazing-feature`)
5. افتح Pull Request

### 5. الإبلاغ عن المشاكل

استخدم GitHub Issues للإبلاغ عن:
- Bugs
- طلبات مميزات جديدة
- تحسينات في الأداء
- مشاكل في التوثيق

### 6. معايير Commit Messages

```
feat: إضافة ميزة جديدة
fix: إصلاح مشكلة
docs: تحديث التوثيق
style: تحسينات في التصميم
refactor: إعادة هيكلة الكود
test: إضافة اختبارات
chore: مهام صيانة
```

### 7. اختبار التغييرات

```bash
# اختبار Backend
cd backend
npm test

# اختبار Frontend
cd frontend
flutter test
```

## المساعدة

إذا كنت تحتاج مساعدة:
- افتح Issue جديد
- راسلنا على البريد الإلكتروني
- انضم لمجتمعنا على Discord

شكراً لمساهمتك! 🚀
