# 🚨 إصلاحات عاجلة مطلوبة

## المشاكل الحالية:

### 1. **TaskPriority غير معرف**
- الملفات المتأثرة: `recent_tasks.dart`, `task_card.dart`
- الحل: إضافة import صحيح للـ TaskPriority

### 2. **Category import conflict**
- الملف: `category_provider.dart`
- الحل: إصلاح return types لاستخدام TaskCategory.Category

### 3. **Methods مفقودة في TaskProvider**
- `toggleTaskCompletion`
- `duplicateTask`

### 4. **Properties مفقودة في AuthProvider**
- `currentUser`
- `getXpForLevel`

### 5. **TaskFilterChip parameters خطأ**
- تغيير `onTap` إلى `onSelected`

### 6. **Math.sqrt مفقود**
- إضافة `import 'dart:math' as math;`

## الحل السريع:
تشغيل `fix-build-errors.bat` مرة أخرى بعد الإصلاحات
