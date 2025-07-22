# تحديثات مطلوبة لملف pubspec.yaml

## إضافة حزمة Excel
لدعم قراءة ملف Excel، أضف الحزمة التالية إلى قسم dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # حزمة قراءة ملفات Excel
  excel: ^4.0.6
  
  # حزم أخرى موجودة...
```

## إضافة ملف Excel إلى Assets
أضف ملف الإدارات إلى قسم flutter assets:

```yaml
flutter:
  uses-material-design: true
  
  # إضافة الخطوط
  fonts:
    - family: Inter
      fonts:
        - asset: fonts/Inter-Regular.ttf
        - asset: fonts/Inter-Medium.ttf
          weight: 500
        - asset: fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: fonts/Inter-Bold.ttf
          weight: 700

  # إضافة الأصول (Assets)
  assets:
    - assets/
    - assets/__الإدارات وفروعها_.xlsx
```

## تشغيل الأمر لتحديث الحزم
بعد تحديث pubspec.yaml، شغل الأمر التالي:

```bash
flutter pub get
```

## ملاحظات مهمة

1. **تنسيق ملف Excel**: تأكد من أن ملف Excel يتبع التنسيق التالي:
   - العمود A: الإدارة التنفيذية
   - العمود B: الإدارة الفرعية/القسم
   - الصف الأول: رؤوس الأعمدة (سيتم تجاهله)

2. **مثال على محتوى ملف Excel**:
   ```
   الإدارة التنفيذية    |    الإدارة الفرعية
   الشؤون الطبية       |    قسم الطوارئ
   الشؤون الطبية       |    قسم العناية المركزة
   التمريض            |    تمريض الطوارئ
   التمريض            |    تمريض العناية المركزة
   ```

3. **الترميز**: تأكد من حفظ ملف Excel بترميز UTF-8 لدعم النصوص العربية

4. **حجم الملف**: لتحسين الأداء، حافظ على حجم ملف Excel معقول

## تفعيل قراءة Excel الفعلية

لتفعيل قراءة ملف Excel الفعلي بدلاً من البيانات الافتراضية، قم بما يلي:

1. فك التعليق عن الكود في نهاية ملف `departments_service.dart`
2. أضف الـ imports المطلوبة:
   ```dart
   import 'dart:typed_data';
   import 'package:flutter/services.dart';
   import 'package:excel/excel.dart';
   ```
3. استبدل دالة `loadDepartments()` باستدعاء `_loadFromExcel()`
