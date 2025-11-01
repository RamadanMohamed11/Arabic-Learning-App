import 'package:shared_preferences/shared_preferences.dart';

class UserProgressService {
  static const String _keyFirstTime = 'first_time';
  static const String _keyPlacementTestScore = 'placement_test_score';
  static const String _keyCurrentLevel = 'current_level';
  static const String _keyLevel1Unlocked = 'level1_unlocked';
  static const String _keyLevel2Unlocked = 'level2_unlocked';
  static const String _keyLevel1Progress = 'level1_progress';
  static const String _keyLevel2Progress = 'level2_progress';
  static const String _keyLevel1Completed = 'level1_completed';
  static const String _keyLevel2Completed = 'level2_completed';
  static const String _keyUnlockedLetters = 'unlocked_letters';
  static const String _keyCompletedActivities = 'completed_activities';
  static const String _keyLevel1UnlockedLessons = 'level1_unlocked_lessons';
  static const String _keyLevel2UnlockedLessons = 'level2_unlocked_lessons';
  static const String _keyCompletedRevisions = 'completed_revisions';
  static const String _keyUserName = 'user_name';
  static const String _keyWelcomeScreenSeen = 'welcome_screen_seen';

  // Singleton pattern
  static UserProgressService? _instance;
  static SharedPreferences? _prefs;

  UserProgressService._();

  static Future<UserProgressService> getInstance() async {
    if (_instance == null) {
      _instance = UserProgressService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('UserProgressService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // التحقق من أول مرة
  bool isFirstTime() {
    return prefs.getBool(_keyFirstTime) ?? true;
  }

  Future<void> setFirstTime(bool value) async {
    await prefs.setBool(_keyFirstTime, value);
  }

  // شاشة الترحيب
  bool hasSeenWelcomeScreen() {
    return prefs.getBool(_keyWelcomeScreenSeen) ?? false;
  }

  Future<void> setWelcomeScreenSeen(bool value) async {
    await prefs.setBool(_keyWelcomeScreenSeen, value);
  }

  // اسم المستخدم
  String? getUserName() {
    return prefs.getString(_keyUserName);
  }

  Future<void> saveUserName(String name) async {
    await prefs.setString(_keyUserName, name);
    await setWelcomeScreenSeen(true);
  }

  // نتيجة اختبار تحديد المستوى
  int getPlacementTestScore() {
    return prefs.getInt(_keyPlacementTestScore) ?? 0;
  }

  Future<void> setPlacementTestScore(int score) async {
    await prefs.setInt(_keyPlacementTestScore, score);
  }

  // المستوى الحالي
  int getCurrentLevel() {
    return prefs.getInt(_keyCurrentLevel) ?? 1;
  }

  Future<void> setCurrentLevel(int level) async {
    await prefs.setInt(_keyCurrentLevel, level);
  }

  // فتح المستويات
  bool isLevel1Unlocked() {
    return prefs.getBool(_keyLevel1Unlocked) ?? true; // المستوى الأول مفتوح دائماً
  }

  bool isLevel2Unlocked() {
    return prefs.getBool(_keyLevel2Unlocked) ?? false;
  }

  Future<void> unlockLevel2() async {
    await prefs.setBool(_keyLevel2Unlocked, true);
  }

  // التقدم في المستويات (0-100)
  double getLevel1Progress() {
    return prefs.getDouble(_keyLevel1Progress) ?? 0.0;
  }

  Future<void> setLevel1Progress(double progress) async {
    await prefs.setDouble(_keyLevel1Progress, progress);
  }

  double getLevel2Progress() {
    return prefs.getDouble(_keyLevel2Progress) ?? 0.0;
  }

  Future<void> setLevel2Progress(double progress) async {
    await prefs.setDouble(_keyLevel2Progress, progress);
  }

  // إكمال المستويات
  bool isLevel1Completed() {
    return prefs.getBool(_keyLevel1Completed) ?? false;
  }

  Future<void> setLevel1Completed(bool completed) async {
    await prefs.setBool(_keyLevel1Completed, completed);
  }

  bool isLevel2Completed() {
    return prefs.getBool(_keyLevel2Completed) ?? false;
  }

  Future<void> setLevel2Completed(bool completed) async {
    await prefs.setBool(_keyLevel2Completed, completed);
  }

  // الحروف المفتوحة (قائمة من الأرقام)
  List<int> getUnlockedLetters() {
    final List<String>? letters = prefs.getStringList(_keyUnlockedLetters);
    if (letters == null) {
      return [0]; // أول حرف مفتوح افتراضياً
    }
    return letters.map((e) => int.parse(e)).toList();
  }

  Future<void> unlockLetter(int letterIndex) async {
    final unlockedLetters = getUnlockedLetters();
    if (!unlockedLetters.contains(letterIndex)) {
      unlockedLetters.add(letterIndex);
      await prefs.setStringList(
        _keyUnlockedLetters,
        unlockedLetters.map((e) => e.toString()).toList(),
      );
    }
  }

  // الأنشطة المكتملة (مفتاح: حرف_نشاط)
  Set<String> getCompletedActivities() {
    final List<String>? activities = prefs.getStringList(_keyCompletedActivities);
    return activities?.toSet() ?? {};
  }

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
  
  /// تحديث شريط التقدم بناءً على الحروف المفتوحة
  Future<void> _updateProgressBar() async {
    final unlockedCount = getUnlockedLetters().length;
    final progress = (unlockedCount / 28) * 100;
    await setLevel1Progress(progress);
    
    // إذا تم إكمال جميع الحروف
    if (unlockedCount >= 28) {
      await setLevel1Completed(true);
    }
  }

  bool isActivityCompleted(int letterIndex, int activityIndex) {
    final completedActivities = getCompletedActivities();
    return completedActivities.contains('${letterIndex}_$activityIndex');
  }

  // إكمال حرف وفتح الحرف التالي
  Future<void> completeLetter(int letterIndex) async {
    // فتح الحرف التالي
    if (letterIndex < 27) { // 28 حرف (0-27)
      await unlockLetter(letterIndex + 1);
      
      // Also ensure the lesson for the next letter is unlocked
      final nextLetterLessonIndex = (letterIndex + 1) ~/ 4;
      await unlockLevel1Lesson(nextLetterLessonIndex);
    }
    
    // تحديث التقدم
    await _updateProgressBar();
  }

  // إعادة تعيين كل شيء
  Future<void> resetAll() async {
    await prefs.clear();
  }

  // إدارة الدروس المفتوحة في المستوى الأول
  List<int> getLevel1UnlockedLessons() {
    final List<String>? lessons = prefs.getStringList(_keyLevel1UnlockedLessons);
    if (lessons == null) {
      return [0]; // أول درس مفتوح افتراضياً (الحروف الأولى)
    }
    return lessons.map((e) => int.parse(e)).toList();
  }

  Future<void> unlockLevel1Lesson(int lessonIndex) async {
    final unlockedLessons = getLevel1UnlockedLessons();
    if (!unlockedLessons.contains(lessonIndex)) {
      unlockedLessons.add(lessonIndex);
      await prefs.setStringList(
        _keyLevel1UnlockedLessons,
        unlockedLessons.map((e) => e.toString()).toList(),
      );
    }
  }

  bool isLevel1LessonUnlocked(int lessonIndex) {
    return getLevel1UnlockedLessons().contains(lessonIndex);
  }

  // إدارة الدروس المفتوحة في المستوى الثاني
  List<int> getLevel2UnlockedLessons() {
    final List<String>? lessons = prefs.getStringList(_keyLevel2UnlockedLessons);
    if (lessons == null) {
      return []; // لا توجد دروس مفتوحة افتراضياً
    }
    return lessons.map((e) => int.parse(e)).toList();
  }

  Future<void> unlockLevel2Lesson(int lessonIndex) async {
    final unlockedLessons = getLevel2UnlockedLessons();
    if (!unlockedLessons.contains(lessonIndex)) {
      unlockedLessons.add(lessonIndex);
      await prefs.setStringList(
        _keyLevel2UnlockedLessons,
        unlockedLessons.map((e) => e.toString()).toList(),
      );
    }
  }

  bool isLevel2LessonUnlocked(int lessonIndex) {
    return getLevel2UnlockedLessons().contains(lessonIndex);
  }

  // إدارة اختبارات المراجعة المكتملة
  List<int> getCompletedRevisions() {
    final List<String>? revisions = prefs.getStringList(_keyCompletedRevisions);
    if (revisions == null) {
      return [];
    }
    return revisions.map((e) => int.parse(e)).toList();
  }

  Future<void> completeRevision(int revisionIndex) async {
    final completedRevisions = getCompletedRevisions();
    if (!completedRevisions.contains(revisionIndex)) {
      completedRevisions.add(revisionIndex);
      await prefs.setStringList(
        _keyCompletedRevisions,
        completedRevisions.map((e) => e.toString()).toList(),
      );
    }
  }

  bool isRevisionCompleted(int revisionIndex) {
    return getCompletedRevisions().contains(revisionIndex);
  }

  // إعداد المستويات بعد نجاح اختبار تحديد المستوى
  Future<void> setupLevelsAfterPlacementTest({required bool passed}) async {
    if (passed) {
      // فتح كلا المستويين
      await unlockLevel2();
      
      // فتح أول درس في كل مستوى فقط
      await prefs.setStringList(_keyLevel1UnlockedLessons, ['0']); // أول درس في المستوى الأول
      await prefs.setStringList(_keyLevel2UnlockedLessons, ['0']); // أول درس في المستوى الثاني
      
      // فتح أول حرف فقط في المستوى الأول (الألف)
      await prefs.setStringList(_keyUnlockedLetters, ['0']);
      
      // تعيين المستوى الحالي إلى 1 (يمكن للمستخدم اختيار أي مستوى)
      await setCurrentLevel(1);
      
      // إعادة تعيين التقدم
      await setLevel1Progress(0.0);
      await setLevel2Progress(0.0);
      await prefs.setBool(_keyLevel1Completed, false);
      await prefs.setBool(_keyLevel2Completed, false);
    } else {
      // فتح المستوى الأول فقط مع أول درس
      await prefs.setStringList(_keyLevel1UnlockedLessons, ['0']);
      await prefs.setStringList(_keyLevel2UnlockedLessons, []); // لا توجد دروس مفتوحة في المستوى الثاني
      await prefs.setStringList(_keyUnlockedLetters, ['0']); // أول حرف فقط
      await setCurrentLevel(1);
    }
  }

  // إعادة تعيين مستوى معين
  Future<void> resetLevel(int level) async {
    if (level == 1) {
      await prefs.setDouble(_keyLevel1Progress, 0.0);
      await prefs.setBool(_keyLevel1Completed, false);
      await prefs.setStringList(_keyUnlockedLetters, ['0']);
      await prefs.setStringList(_keyCompletedActivities, []);
      await prefs.setStringList(_keyLevel1UnlockedLessons, ['0']);
    } else if (level == 2) {
      await prefs.setDouble(_keyLevel2Progress, 0.0);
      await prefs.setBool(_keyLevel2Completed, false);
      await prefs.setStringList(_keyLevel2UnlockedLessons, []);
    }
  }
}
