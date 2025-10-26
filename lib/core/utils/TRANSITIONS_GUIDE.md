# دليل الانتقالات المتحركة (Page Transitions Guide)

## نظرة عامة
تم إضافة نظام شامل للانتقالات المتحركة الجميلة بين الصفحات في التطبيق. يتضمن النظام نوعين من الانتقالات:

1. **PageTransitions** - للاستخدام مع `go_router`
2. **AnimatedRoute** - للاستخدام مع `Navigator.push`

---

## 🎨 أنواع الانتقالات المتاحة

### 1. **fadeScale** - تلاشي مع تكبير
- **الاستخدام**: مثالي للصفحات الرئيسية والترحيبية
- **المدة**: 400ms
- **التأثير**: الصفحة تظهر بتلاشي وتكبير تدريجي من 92% إلى 100%

```dart
// مع go_router
PageTransitions.fadeScale(child: const MyPage(), state: state)

// مع Navigator.push
Navigator.push(context, AnimatedRoute.fadeScale(const MyPage()))
```

---

### 2. **slideRight** - انزلاق من اليمين
- **الاستخدام**: مثالي للتنقل للأمام في التطبيق
- **المدة**: 350ms
- **التأثير**: الصفحة تنزلق من اليمين مع تلاشي

```dart
// مع go_router
PageTransitions.slideRight(child: const MyPage(), state: state)

// مع Navigator.push
Navigator.push(context, AnimatedRoute.slideRight(const MyPage()))
```

---

### 3. **slideLeft** - انزلاق من اليسار
- **الاستخدام**: مثالي للرجوع أو التنقل للخلف
- **المدة**: 350ms
- **التأثير**: الصفحة تنزلق من اليسار مع تلاشي

```dart
// مع go_router فقط
PageTransitions.slideLeft(child: const MyPage(), state: state)
```

---

### 4. **slideUp** - انزلاق من الأسفل
- **الاستخدام**: مثالي للنوافذ المنبثقة والشاشات الثانوية
- **المدة**: 400ms
- **التأثير**: الصفحة تنزلق من الأسفل للأعلى مع تلاشي

```dart
// مع go_router
PageTransitions.slideUp(child: const MyPage(), state: state)

// مع Navigator.push
Navigator.push(context, AnimatedRoute.slideUp(const MyPage()))
```

---

### 5. **rotationFade** - دوران مع تلاشي
- **الاستخدام**: مثالي للصفحات الخاصة أو التفاعلية
- **المدة**: 500ms
- **التأثير**: الصفحة تدور قليلاً وتتكبر مع التلاشي

```dart
// مع go_router
PageTransitions.rotationFade(child: const MyPage(), state: state)

// مع Navigator.push
Navigator.push(context, AnimatedRoute.rotationFade(const MyPage()))
```

---

### 6. **slideScale** - انزلاق مع تكبير
- **الاستخدام**: مثالي للانتقالات السلسة والأنيقة
- **المدة**: 450ms
- **التأثير**: الصفحة تنزلق وتتكبر مع التلاشي
- **ملاحظة**: يمكن تخصيص اتجاه الانزلاق

```dart
// مع go_router
PageTransitions.slideScale(child: const MyPage(), state: state)

// مع Navigator.push
Navigator.push(context, AnimatedRoute.slideScale(const MyPage()))

// مع اتجاه مخصص
Navigator.push(
  context, 
  AnimatedRoute.slideScale(
    const MyPage(), 
    beginOffset: const Offset(0.5, 0.0)
  )
)
```

---

### 7. **elegantZoom** - زووم أنيق
- **الاستخدام**: مثالي للصفحات التفاعلية والألعاب
- **المدة**: 500ms
- **التأثير**: الصفحة تتكبر بشكل أنيق مع تلاشي (من 70% إلى 100%)
- **المنحنى**: `Curves.easeInOutBack` - يعطي تأثير ارتداد خفيف

```dart
// مع go_router
PageTransitions.elegantZoom(child: const MyPage(), state: state)

// مع Navigator.push
Navigator.push(context, AnimatedRoute.elegantZoom(const MyPage()))
```

---

### 8. **fade** - تلاشي بسيط
- **الاستخدام**: مثالي للانتقالات السريعة والبسيطة
- **المدة**: 300ms
- **التأثير**: تلاشي بسيط فقط

```dart
// مع go_router
PageTransitions.fade(child: const MyPage(), state: state)

// مع Navigator.push
Navigator.push(context, AnimatedRoute.fade(const MyPage()))
```

---

### 9. **sharedAxisHorizontal** - محور مشترك أفقي
- **الاستخدام**: مثالي للتنقل بين الأقسام الرئيسية
- **المدة**: 400ms
- **التأثير**: الصفحة الجديدة تنزلق من اليمين بينما القديمة تنزلق لليسار
- **ملاحظة**: متاح فقط مع `go_router`

```dart
// مع go_router فقط
PageTransitions.sharedAxisHorizontal(child: const MyPage(), state: state)
```

---

## 📝 أمثلة الاستخدام

### مع go_router في app_router.dart

```dart
GoRoute(
  path: '/my-page',
  pageBuilder: (context, state) => PageTransitions.slideScale(
    child: const MyPage(),
    state: state,
  ),
)
```

### مع Navigator.push في أي صفحة

```dart
// بدلاً من:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MyPage()),
)

// استخدم:
Navigator.push(
  context,
  AnimatedRoute.slideScale(const MyPage()),
)
```

---

## 🎯 التوصيات

| نوع الصفحة | الانتقال الموصى به | السبب |
|-----------|-------------------|--------|
| صفحة الترحيب | `fadeScale` | يعطي انطباع أول جميل |
| الصفحات الرئيسية | `elegantZoom` | يبرز أهمية الصفحة |
| التنقل للأمام | `slideRight` أو `slideScale` | يوضح اتجاه التنقل |
| النوافذ المنبثقة | `slideUp` | يشبه السلوك المعتاد للنوافذ |
| صفحات الألعاب | `rotationFade` أو `elegantZoom` | يضيف حيوية |
| الانتقالات السريعة | `fade` | سريع وبسيط |
| بين الأقسام | `sharedAxisHorizontal` | يوضح العلاقة بين الأقسام |

---

## 🔧 تخصيص المدة

يمكنك تخصيص مدة الانتقال:

```dart
// مع go_router
PageTransitions.slideScale(
  child: const MyPage(),
  state: state,
  duration: const Duration(milliseconds: 600), // مدة مخصصة
)
```

---

## 📚 الملفات ذات الصلة

- `lib/core/utils/page_transitions.dart` - للاستخدام مع go_router
- `lib/core/utils/animated_route.dart` - للاستخدام مع Navigator.push
- `lib/core/utils/app_router.dart` - تطبيق الانتقالات على المسارات

---

## ✨ نصائح

1. **الاتساق**: استخدم نفس نوع الانتقال للصفحات المتشابهة
2. **الأداء**: الانتقالات الأقصر (300-400ms) أفضل للأداء
3. **تجربة المستخدم**: لا تستخدم انتقالات معقدة جداً قد تشتت المستخدم
4. **الاختبار**: جرب الانتقالات على أجهزة مختلفة للتأكد من سلاستها

---

## 🎨 المنحنيات المستخدمة

- `Curves.easeInOutCubic` - سلس ومتوازن
- `Curves.easeOutCubic` - بداية سريعة ونهاية بطيئة
- `Curves.easeInOut` - متوازن للتلاشي
- `Curves.easeInOutBack` - يعطي تأثير ارتداد خفيف

---

تم إنشاء هذا النظام لتحسين تجربة المستخدم وجعل التطبيق أكثر حيوية وجاذبية! 🚀
