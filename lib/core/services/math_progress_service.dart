import 'package:shared_preferences/shared_preferences.dart';

class MathProgressService {
  static const String _keyMathLevel1Unlocked = 'math_level1_unlocked';
  static const String _keyMathLevel2Unlocked = 'math_level2_unlocked';
  static const String _keyMathLevel3Unlocked = 'math_level3_unlocked';

  static const String _keyMathLevel1Completed = 'math_level1_completed';
  static const String _keyMathLevel2Completed = 'math_level2_completed';
  static const String _keyMathLevel3Completed = 'math_level3_completed';

  static const String _keyMathUnlockedNumbers = 'math_unlocked_numbers_v2';
  static const String _keyMathCompletedActivities = 'math_completed_activities_v2';

  // Singleton pattern
  static MathProgressService? _instance;
  static SharedPreferences? _prefs;

  MathProgressService._();

  static Future<MathProgressService> getInstance() async {
    if (_instance == null) {
      _instance = MathProgressService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'MathProgressService not initialized. Call init() first.',
      );
    }
    return _prefs!;
  }

  // --- Levels Unlocked ---
  bool isLevel1Unlocked() {
    return prefs.getBool(_keyMathLevel1Unlocked) ?? true; // Level 1 is always unlocked
  }

  bool isLevel2Unlocked() {
    return prefs.getBool(_keyMathLevel2Unlocked) ?? false;
  }

  Future<void> unlockLevel2() async {
    await prefs.setBool(_keyMathLevel2Unlocked, true);
  }

  bool isLevel3Unlocked() {
    return prefs.getBool(_keyMathLevel3Unlocked) ?? false;
  }

  Future<void> unlockLevel3() async {
    await prefs.setBool(_keyMathLevel3Unlocked, true);
  }

  // --- Levels Completed ---
  bool isLevel1Completed() {
    return prefs.getBool(_keyMathLevel1Completed) ?? false;
  }

  Future<void> setLevel1Completed(bool completed) async {
    await prefs.setBool(_keyMathLevel1Completed, completed);
    if (completed) {
      await unlockLevel2();
      // Unlock the first number of level 2 (which is 10)
      await unlockNumber(2, 10);
    }
  }

  bool isLevel2Completed() {
    return prefs.getBool(_keyMathLevel2Completed) ?? false;
  }

  Future<void> setLevel2Completed(bool completed) async {
    await prefs.setBool(_keyMathLevel2Completed, completed);
    if (completed) {
      await unlockLevel3();
      // Unlock the first number of level 3 (which is 21)
      await unlockNumber(3, 21);
    }
  }

  bool isLevel3Completed() {
    return prefs.getBool(_keyMathLevel3Completed) ?? false;
  }

  Future<void> setLevel3Completed(bool completed) async {
    await prefs.setBool(_keyMathLevel3Completed, completed);
  }

  // --- Numbers Unlocked ---
  List<String> getUnlockedNumbers() {
    return prefs.getStringList(_keyMathUnlockedNumbers) ?? [];
  }

  Future<void> unlockNumber(int level, int number) async {
    final unlockedNumbers = getUnlockedNumbers();
    final key = '${level}_$number';
    if (!unlockedNumbers.contains(key)) {
      unlockedNumbers.add(key);
      await prefs.setStringList(
        _keyMathUnlockedNumbers,
        unlockedNumbers,
      );
    }
  }

  bool isNumberUnlocked(int level, int number) {
    if (level == 1 && number == 1) return true; // Level 1 starts with 1 unlocked
    if (level == 2 && number == 10 && isLevel2Unlocked()) return true; // Level 2 starts with 10 unlocked
    if (level == 3 && number == 21 && isLevel3Unlocked()) return true; // Level 3 starts with 21 unlocked
    
    final key = '${level}_$number';
    return getUnlockedNumbers().contains(key);
  }

  // --- Activities Completed ---
  Set<String> getCompletedActivities() {
    final List<String>? activities = prefs.getStringList(
      _keyMathCompletedActivities,
    );
    return activities?.toSet() ?? {};
  }

  Future<void> completeActivity(int level, int number, int activityIndex) async {
    final completedActivities = getCompletedActivities();
    completedActivities.add('${level}_${number}_$activityIndex');
    await prefs.setStringList(
      _keyMathCompletedActivities,
      completedActivities.toList(),
    );
  }

  bool isActivityCompleted(int level, int number, int activityIndex) {
    final completedActivities = getCompletedActivities();
    return completedActivities.contains('${level}_${number}_$activityIndex');
  }

  // Activity progression: Once all 4 activities are done for a number, it is completed.
  bool isNumberCompleted(int level, int number, {int totalActivities = 4}) {
    for (int i = 0; i < totalActivities; i++) {
      if (!isActivityCompleted(level, number, i)) {
        return false;
      }
    }
    return true;
  }

  // --- Reset ---
  Future<void> resetAllMathProgress() async {
    await prefs.remove(_keyMathLevel1Unlocked);
    await prefs.remove(_keyMathLevel2Unlocked);
    await prefs.remove(_keyMathLevel3Unlocked);
    await prefs.remove(_keyMathLevel1Completed);
    await prefs.remove(_keyMathLevel2Completed);
    await prefs.remove(_keyMathLevel3Completed);
    await prefs.remove(_keyMathUnlockedNumbers);
    await prefs.remove(_keyMathCompletedActivities);
  }
}
