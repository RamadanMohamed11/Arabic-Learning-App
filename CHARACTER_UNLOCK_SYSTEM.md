# نظام فتح الحروف - Character Unlock System

## 📋 النظام الحالي

تم تطبيق نظام فتح الحروف بناءً على النجاح في اختبارات المراجعة.

---

## 🎯 كيف يعمل النظام

### القاعدة الأساسية
- **يجب** الحصول على **100%** (جميع الإجابات صحيحة) في اختبار المراجعة
- عند النجاح بنسبة 100%، يتم فتح **حرف واحد جديد** (أول حرف من المجموعة التالية)

---

## 📊 تقسيم المجموعات

### المجموعة 0 (الأولى) - مفتوحة افتراضياً
- **الحروف**: ا، ب، ت، ث
- **الفهرس**: 0-3

### المجموعة 1 (الثانية)
- **الحروف**: ج، ح، خ، د
- **الفهرس**: 4-7
- **يتم فتح الحرف الأول (ج)**: بعد نجاح 100% في اختبار المجموعة 0

### المجموعة 2 (الثالثة)
- **الحروف**: ذ، ر، ز، س
- **الفهرس**: 8-11
- **يتم فتح الحرف الأول (ذ)**: بعد نجاح 100% في اختبار المجموعة 1

### المجموعة 3 (الرابعة)
- **الحروف**: ش، ص، ض، ط
- **الفهرس**: 12-15
- **يتم فتح الحرف الأول (ش)**: بعد نجاح 100% في اختبار المجموعة 2

### المجموعة 4 (الخامسة)
- **الحروف**: ظ، ع، غ، ف
- **الفهرس**: 16-19
- **يتم فتح الحرف الأول (ظ)**: بعد نجاح 100% في اختبار المجموعة 3

### المجموعة 5 (السادسة)
- **الحروف**: ق، ك، ل، م
- **الفهرس**: 20-23
- **يتم فتح الحرف الأول (ق)**: بعد نجاح 100% في اختبار المجموعة 4

### المجموعة 6 (السابعة - الأخيرة)
- **الحروف**: ن، ه، و، ي
- **الفهرس**: 24-27
- **يتم فتح الحرف الأول (ن)**: بعد نجاح 100% في اختبار المجموعة 5

---

## 🔄 سير العمل

```
1. المستخدم يبدأ بـ 4 حروف مفتوحة (ا، ب، ت، ث)
                ↓
2. يتعلم هذه الحروف ويمارس عليها
                ↓
3. يدخل اختبار المراجعة للمجموعة 0
                ↓
4. إذا حصل على 100% (4/4 صحيحة)
                ↓
5. ✅ يُفتح الحرف التالي (ج)
   ✅ يُفتح اختبار المراجعة للمجموعة 1
   ✅ يتم تحديث شريط التقدم
                ↓
6. يكرر العملية للحروف التالية
```

---

## 💡 ملاحظات مهمة

### النسب المطلوبة
- **75%** = اختبار ناجح (رسالة "ممتاز!")
- **100%** = اختبار مثالي (فتح الحرف الجديد + رسالة "مذهل! 🌟")

### الرسائل المعروضة
- **100%**: "إجابات مثالية! تم فتح الحرف التالي 🎉"
- **75-99%**: "أحسنت! لقد أتقنت هذه المجموعة"
- **أقل من 75%**: "استمر في التدريب لتحسين نتيجتك"

### عرض الحرف المفتوح
عند الحصول على 100%، يتم عرض صندوق أخضر يحتوي على:
- 🔓 أيقونة القفل المفتوح
- نص "حرف جديد مفتوح!"
- الحرف الجديد بخط كبير

### شريط التقدم
- يتم تحديث شريط التقدم تلقائياً بعد:
  - إكمال أي نشاط (تتبع، تمرين، إلخ)
  - النجاح في اختبار المراجعة بنسبة 100%
  - فتح حرف جديد
- النسبة المئوية = (عدد الحروف المفتوحة / 28) × 100

---

## 🛠️ التفاصيل التقنية

### الملفات المعدلة
```
lib/features/exercises/presentation/views/revision_test_view.dart
lib/core/services/user_progress_service.dart
```

### التعديلات الرئيسية

#### 1. إضافة UserProgressService
```dart
UserProgressService? _progressService;

Future<void> _loadProgressService() async {
  _progressService = await UserProgressService.getInstance();
}
```

#### 2. منطق فتح الحرف الواحد
```dart
Future<void> _checkAndUnlockNextLetters() async {
  if (_progressService == null) return;
  
  final isPerfectScore = _score == _testGroup.questions.length;
  
  if (isPerfectScore) {
    // حساب فهرس الحرف التالي
    final nextLetterIndex = (widget.groupNumber + 1) * 4;
    
    // فتح الحرف التالي فقط
    if (nextLetterIndex < 28) {
      await _progressService!.unlockLetter(nextLetterIndex);
      
      // تحديث شريط التقدم
      final unlockedCount = _progressService!.getUnlockedLetters().length;
      final progress = (unlockedCount / 28) * 100;
      await _progressService!.setLevel1Progress(progress);
    }
    
    // فتح المجموعة/الدرس التالي
    if (widget.groupNumber < 6) {
      await _progressService!.unlockLevel1Lesson(widget.groupNumber + 1);
    }
  }
}
```

#### 3. تحديث شريط التقدم التلقائي (في UserProgressService)
```dart
Future<void> completeActivity(int letterIndex, int activityIndex) async {
  final completedActivities = getCompletedActivities();
  completedActivities.add('${letterIndex}_$activityIndex');
  await prefs.setStringList(
    _keyCompletedActivities,
    completedActivities.toList(),
  );
  
  // تحديث شريط التقدم بعد إكمال أي نشاط
  await _updateProgressBar();
}

Future<void> _updateProgressBar() async {
  final unlockedCount = getUnlockedLetters().length;
  final progress = (unlockedCount / 28) * 100;
  await setLevel1Progress(progress);
  
  if (unlockedCount >= 28) {
    await setLevel1Completed(true);
  }
}
```

#### 4. واجهة النتائج المحدثة
- عرض رسالة خاصة للنتيجة المثالية
- صندوق أخضر يعرض الحرف المفتوح
- أيقونات وألوان مميزة
- تصميم متجاوب مع SingleChildScrollView لتجنب overflow

---

## 🔮 للمستقبل

عندما يتم إضافة اختبارات جديدة:

```dart
// سيتم تعديل المنطق ليكون:
// 1. يجب النجاح في جميع الاختبارات
// 2. بنسبة 100% في كل اختبار
// 3. ثم يتم فتح الحروف التالية

// مثال:
bool allTestsPassed = 
  listeningTestScore == 100 && 
  writingTestScore == 100 && 
  speakingTestScore == 100;

if (allTestsPassed) {
  unlockNextLetters();
}
```

---

## ✅ الفوائد

1. **تدرج تعليمي**: المستخدم يتعلم بشكل تدريجي
2. **تحفيز**: الحصول على 100% يفتح محتوى جديد
3. **إتقان**: يضمن إتقان الحروف قبل الانتقال
4. **تقييم واضح**: النسب المختلفة تعطي تغذية راجعة واضحة

---

## 📝 ملخص

- ✅ نظام فتح تدريجي للحروف
- ✅ يتطلب 100% في الاختبار
- ✅ رسائل تحفيزية وواضحة
- ✅ عرض مرئي للحروف الجديدة
- ✅ جاهز للتوسع بإضافة اختبارات جديدة

---

تاريخ التحديث: أكتوبر 2025
الإصدار: 1.0.0
