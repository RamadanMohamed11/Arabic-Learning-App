# Placement Test Lesson Unlocking System

## 🎯 New Behavior: When User Passes Placement Test

### ✅ What Happens Now:
When a user passes the placement test (≥50% score) for the first time:

1. **Both Level 1 and Level 2 are unlocked**
2. **Only the first lesson in each level is accessible**
3. **Other lessons remain locked until progression**

### ✅ What Happens if User Fails:
When a user fails the placement test (<50% score):

1. **Only Level 1 is unlocked**
2. **Only the first lesson in Level 1 is accessible**
3. **Level 2 remains completely locked**

## 📚 Lesson Structure

### Level 1 - Arabic Letters (28 letters total)
- **Lesson 0**: Letters 1-4 (ا، ب، ت، ث)
- **Lesson 1**: Letters 5-8 (ج، ح، خ، د)
- **Lesson 2**: Letters 9-12 (ذ، ر، ز، س)
- **Lesson 3**: Letters 13-16 (ش، ص، ض، ط)
- **Lesson 4**: Letters 17-20 (ظ، ع، غ، ف)
- **Lesson 5**: Letters 21-24 (ق، ك، ل، م)
- **Lesson 6**: Letters 25-28 (ن، ه، و، ي)

### Level 2 - Word & Sentence Formation (6 activities)
- **Lesson 0**: تجميع الحروف (Letter Assembly)
- **Lesson 1**: قراءة الكلمات (Word Reading)
- **Lesson 2**: كتابة الكلمات (Word Writing)
- **Lesson 3**: تكوين الجمل (Sentence Formation)
- **Lesson 4**: قراءة الجمل (Sentence Reading)
- **Lesson 5**: مراجعة شاملة (Comprehensive Review)

## 🔧 Technical Implementation

### New UserProgressService Methods:

#### Lesson Management:
```dart
// Level 1 Lessons
List<int> getLevel1UnlockedLessons()
Future<void> unlockLevel1Lesson(int lessonIndex)
bool isLevel1LessonUnlocked(int lessonIndex)

// Level 2 Lessons
List<int> getLevel2UnlockedLessons()
Future<void> unlockLevel2Lesson(int lessonIndex)
bool isLevel2LessonUnlocked(int lessonIndex)
```

#### Placement Test Setup:
```dart
Future<void> setupLevelsAfterPlacementTest({required bool passed})
```

### Modified Files:

#### 1. `lib/core/services/user_progress_service.dart`
- ✅ Added lesson tracking keys
- ✅ Added lesson management methods
- ✅ Added `setupLevelsAfterPlacementTest()` method
- ✅ Updated `resetLevel()` to handle lessons

#### 2. `lib/features/placement_test/presentation/views/widgets/placement_test_view_body.dart`
- ✅ Simplified `_showResults()` method
- ✅ Uses new `setupLevelsAfterPlacementTest()` method

#### 3. `lib/features/level_one/presentation/views/level_one_view.dart`
- ✅ Added `_unlockedLessons` tracking
- ✅ Modified letter unlocking logic to consider lessons
- ✅ Letters are grouped by lessons (4 letters per lesson)

#### 4. `lib/features/level_two/presentation/views/level_two_view.dart`
- ✅ Added `_unlockedLessons` tracking
- ✅ Modified activity unlocking to use lesson system
- ✅ Each activity is now a separate lesson

## 📱 User Experience

### Scenario 1: User Passes Placement Test (≥50%)
1. **Levels Selection Screen**: Both Level 1 and Level 2 are visible and unlocked
2. **Level 1**: Only first 4 letters (ا، ب، ت، ث) are accessible
3. **Level 2**: Only first activity (تجميع الحروف) is accessible
4. **Progression**: User must complete lessons to unlock more content

### Scenario 2: User Fails Placement Test (<50%)
1. **Levels Selection Screen**: Only Level 1 is unlocked, Level 2 is locked
2. **Level 1**: Only first 4 letters (ا، ب، ت، ث) are accessible
3. **Level 2**: Completely inaccessible
4. **Progression**: User must complete Level 1 to unlock Level 2

## 🎮 Progression System

### Level 1 Progression:
- Complete letters in Lesson 0 → Unlock Lesson 1 (next 4 letters)
- Complete letters in Lesson 1 → Unlock Lesson 2 (next 4 letters)
- Continue until all 7 lessons are completed

### Level 2 Progression:
- Complete Activity 0 → Unlock Activity 1
- Complete Activity 1 → Unlock Activity 2
- Continue until all 6 activities are completed

## 🔄 Migration & Compatibility

### For Existing Users:
- Existing progress is preserved
- New lesson system applies to new users only
- Existing users continue with current progression

### For New Users:
- Placement test determines initial unlocking
- Lesson-based progression from the start
- More structured learning path

## 🧪 Testing Scenarios

### Test Case 1: New User Passes Placement Test
1. Take placement test, score ≥50%
2. Verify both levels are unlocked
3. Verify only first lesson in each level is accessible
4. Verify other lessons are locked

### Test Case 2: New User Fails Placement Test
1. Take placement test, score <50%
2. Verify only Level 1 is unlocked
3. Verify Level 2 is locked
4. Verify only first lesson in Level 1 is accessible

### Test Case 3: Lesson Progression
1. Complete first lesson in Level 1
2. Verify second lesson becomes unlocked
3. Verify progression tracking works correctly

## 📊 Benefits

### For Learners:
- ✅ **Structured progression**: Clear learning path
- ✅ **Appropriate challenge**: Content matches skill level
- ✅ **Motivation**: Unlocking new content provides goals
- ✅ **Flexibility**: Can choose between levels if both are unlocked

### For Educators:
- ✅ **Assessment-based placement**: Placement test determines starting point
- ✅ **Controlled progression**: Prevents overwhelming beginners
- ✅ **Progress tracking**: Clear visibility into student advancement
- ✅ **Differentiated learning**: Different paths based on initial assessment

## Date
2025-01-21
