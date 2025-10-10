@echo off
echo 🚀 بدء تشغيل Y0 Task Manager Backend...
echo.

cd backend

echo 📦 تثبيت المكتبات...
call npm install

echo.
echo 🔧 إعداد متغيرات البيئة...
if not exist .env (
    copy .env.example .env
    echo ✅ تم إنشاء ملف .env من .env.example
    echo ⚠️  يرجى تحديث متغيرات البيئة في ملف .env
    pause
)

echo.
echo 🗄️  بدء تشغيل قاعدة البيانات...
docker-compose -f ../docker-compose.yml up -d

echo.
echo ⏳ انتظار قاعدة البيانات...
timeout /t 10 /nobreak

echo.
echo 🚀 بدء تشغيل الخادم...
npm run dev

pause
