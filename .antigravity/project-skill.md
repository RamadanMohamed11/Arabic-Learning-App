---
name: arabic-learning-app-skill
description: Comprehensive reference for the Arabic Learning App Flutter project — architecture, feature map, data layer, audio/TTS, SVG tracing, speech recognition, navigation, coding conventions, and content authoring guides.
---

# Arabic Learning App — Project Skill File

> **Last Updated:** 2026-04-04
> **Version:** 1.0.6+11
> **Min SDK:** Flutter 3.x / Dart 3.x
> **Platform:** Android only (minSdk 23, targetSdk 35)
> **Package:** `com.baraa.arabiclearning`

---

## 1. Project Overview

**App Name:** تعلم العربية (Arabic Learning App)
**Purpose:** An interactive educational app that teaches Arabic letters, words, sentences, and basic math (numbers) to young children. Entirely in Arabic with full TTS narration and speech recognition.
**Target Audience:** Arabic-speaking children (ages 4-8) learning the Arabic alphabet and numbers.

### Key Capabilities
- Letter recognition, shapes (isolated/initial/medial/final), and pronunciation
- Letter tracing via SVG paths on a touch canvas
- Speech-to-text pronunciation practice with diacritic-aware fuzzy matching
- Math module: number recognition, ordering, tracing, listen-and-write, pronunciation
- Multi-level progression system with revision tests and final exams
- Certificate generation upon Level 1 completion
- Placement test for new users
- Memory game for letter reinforcement

---

## 2. Architecture & Patterns

### 2.1 State Management
- **No BLoC/Cubit.** The app uses a **StatefulWidget + service singleton** pattern throughout
- Each screen is a `StatefulWidget` with its own local state
- Shared state lives in **singleton services** (`UserProgressService`, `MathProgressService`, `AppTtsService`)
- Services are initialized via `static Future<T> getInstance()` factory methods backed by Hive/SharedPreferences

### 2.2 Folder Structure
```
lib/
├── main.dart                          # App entry point, TTS warm-up, Hive init
├── constants.dart                     # arabicLetters list, words data
├── core/
│   ├── audio/
│   │   ├── app_tts_service.dart       # TTS singleton with speakScreenIntro()
│   │   └── tts_config.dart            # Platform-specific TTS engine config
│   ├── data/
│   │   └── letter_names.dart          # LetterName model + full 28-letter list
│   ├── models/
│   │   └── letter_shapes.dart         # LetterShapes model (isolated/initial/medial/final)
│   ├── services/
│   │   ├── user_progress_service.dart # Hive-backed progress for Level 1/2
│   │   └── math_progress_service.dart # Hive-backed progress for Math module
│   └── utils/
│       ├── app_colors.dart            # Centralized color palette & gradients
│       ├── app_router.dart            # GoRouter route definitions
│       ├── animated_route.dart        # Navigator.push transition helpers
│       ├── page_transitions.dart      # GoRouter CustomTransitionPage helpers
│       ├── arabic_numbers_extension.dart # int.toArabicDigits() extension
│       ├── assets_data.dart           # Static asset paths
│       └── service_locator.dart       # Empty (DI not used)
├── features/
│   ├── about/                         # About, AppInfo, ContactUs views
│   ├── Alphabet/                      # Letter grid, shapes, exercises
│   ├── certificate/                   # Completion certificate view
│   ├── exercises/                     # Revision tests (selection + execution)
│   ├── home/                          # Subject selection (Arabic vs Math)
│   ├── letter_tracing/                # SVG-based letter tracing canvas
│   ├── level_one/                     # Level 1: letter learning + final test
│   ├── level_two/                     # Level 2: words/sentences activities
│   ├── levels/                        # Level selection screen
│   ├── math/                          # Full math module
│   ├── memory_game/                   # Letter memory card game
│   ├── placement_test/                # Initial placement test
│   ├── pronunciation_practice/        # General pronunciation practice
│   ├── welcome/                       # Welcome/splash screen
│   ├── word_search/                   # Word search puzzle
│   ├── word_training/                 # Word training activities
│   └── writing_practice/              # Writing practice + Gemini test
```

### 2.3 Dependency Injection
- **Not used.** `service_locator.dart` exists but is empty
- All services are accessed via static singleton pattern: `ServiceName.instance` or `await ServiceName.getInstance()`

### 2.4 Navigation Structure
Two navigation systems coexist:

#### GoRouter (primary, for top-level routes)
Defined in `lib/core/utils/app_router.dart`:
```
/welcome                    → WelcomeScreenView
/homeSubjectSelection       → HomeSubjectSelectionView (root after welcome)
/arabicStart                → LevelsSelectionView
/levelOne                   → LevelOneView
/levelTwo                   → LevelTwoView
/alphabet                   → AlphabetView
/writingPractice            → WritingPracticeView
/mathView                   → MathView
/memoryGame                 → MemoryGameViewBody
/wordSearch                 → WordSearchViewBody
/wordTraining               → WordTrainingView
/pronunciationPractice      → PronunciationPracticeViewBody
/certificate                → CertificateView
/placementTest              → PlacementTestViewBody
/about                      → AboutView
/appInfo                    → AppInfoView
/contactUs                  → ContactUsView
```
Transitions use `PageTransitions` helpers (fadeScale, slideRight, elegantZoom, etc.)

#### Navigator.push (for sub-flows within features)
Used for letter-to-activity drill-downs via `AnimatedRoute` helpers:
- `AnimatedRoute.slideRight()` — forward navigation
- `AnimatedRoute.fadeScale()` — level/number selection
- `AnimatedRoute.elegantZoom()` — tests and special screens
- `AnimatedRoute.fade()` — simple transitions

---

## 3. Key Features Map

### 3.1 Feature Status

| Feature | Folder | Status | Description |
|---------|--------|--------|-------------|
| Welcome | `welcome/` | ✅ Complete | Animated splash with TTS intro |
| Home | `home/` | ✅ Complete | Subject selection (Arabic vs Math) |
| Levels | `levels/` | ✅ Complete | Level 1/2 selection |
| Level One | `level_one/` | ✅ Complete | 28 letters, revision tests, final exam |
| Level Two | `level_two/` | ✅ Complete | Word-level activities (7 types) |
| Alphabet | `Alphabet/` | ✅ Complete | Letter grid, shapes, exercises |
| Letter Tracing | `letter_tracing/` | ✅ Complete | SVG path tracing with touch |
| Math | `math/` | ✅ Complete | 3 levels, 4+ activities per number |
| Exercises | `exercises/` | ✅ Complete | Revision tests between letter groups |
| Placement Test | `placement_test/` | ✅ Complete | Initial skill assessment |
| Certificate | `certificate/` | ✅ Complete | Level 1 completion certificate |
| Pronunciation | `pronunciation_practice/` | ✅ Complete | Speech recognition practice |
| Memory Game | `memory_game/` | ✅ Complete | Card matching game |
| Word Search | `word_search/` | ✅ Complete | Puzzle grid |
| Word Training | `word_training/` | ✅ Complete | Word recognition |
| Writing Practice | `writing_practice/` | ✅ Complete | Canvas writing + Gemini AI |
| About | `about/` | ✅ Complete | App info, team, contact |

### 3.2 Level One Activities (per letter)
1. **Letter Shapes** — Shows isolated/initial/medial/final forms
2. **Letter Tracing** — SVG path tracing on canvas
3. **Pronunciation Practice** — Speech recognition for the letter
4. **Letter Test** — Quiz questions per letter

### 3.3 Level One Progression
- Letters grouped in sets of 4
- After completing 4 letters → revision test unlocks
- 7 revision groups total (28 letters ÷ 4)
- After ALL 7 revisions → final test unlocks
- Final test completion → Certificate

### 3.4 Math Activities (per number, Level 1)
1. **Number Tracing** — SVG path tracing
2. **Number Ordering** — Sequence ordering
3. **Listen & Write** — TTS speaks number, child writes it
4. **Number Pronunciation** — Speech recognition for number names

### 3.5 Level Two Activities
1. **Image Name** — Identify image names
2. **Image Description** — Describe images
3. **Word Spelling** — Spell words correctly
4. **Word Match** — Match words to meanings
5. **Missing Word** — Fill in blanks
6. **Sentence Order** — Arrange sentence parts
7. **Final Test** — Comprehensive word-level exam

---

## 4. Data Layer

### 4.1 Hive Boxes

| Box Name | Opened In | Purpose |
|----------|-----------|---------|
| `userProgressBox` | `main.dart` | Stores Level 1 letter progress (unlocked letters, completed activities, revision results) |
| `mathProgressBox` | `main.dart` | Stores Math module progress (level unlocks, number completions, activity tracking) |
| `level2ProgressBox` | `main.dart` | Stores Level 2 word activity progress |

### 4.2 UserProgressService (`core/services/user_progress_service.dart`)
- Singleton via `static Future<UserProgressService> getInstance()`
- Backed by Hive box `userProgressBox`
- **Key methods:**
  - `getUnlockedLetters()` → `List<int>` of unlocked letter indices
  - `getLevel1UnlockedLessons()` → lessons (groups of 4 letters)
  - `getCompletedRevisions()` → completed revision test indices
  - `isActivityCompleted(letterIndex, activityIndex)` → bool
  - `completeActivity(letterIndex, activityIndex)` → marks done + auto-unlocks next
  - `getLevel1Progress()` → percentage 0-100
  - `validateAndCorrectUnlocks()` → auto-corrects stale unlock state

### 4.3 MathProgressService (`core/services/math_progress_service.dart`)
- Singleton via `static Future<MathProgressService> getInstance()`
- Backed by Hive box `mathProgressBox`
- **Key methods:**
  - `isLevel1Unlocked()`, `isLevel2Unlocked()`, `isLevel3Unlocked()`
  - `isNumberCompleted(level, number)` → bool
  - `completeNumber(level, number)` → marks complete
  - `completeActivity(level, number, activityIndex)` → marks activity done + checks number completion
  - `getCompletedNumbersCount(level)` → int

### 4.4 LetterProgressService (`writing_practice/data/services/letter_progress_service.dart`)
- Uses **SharedPreferences** (not Hive)
- Key prefix: `letter_completed_<letter>`
- Key: `unlocked_letters_count`
- Tracks writing practice completion separately from Level 1

### 4.5 SharedPreferences Keys
| Key | Type | Purpose |
|-----|------|---------|
| `letter_completed_<letter>` | bool | Writing practice completion per letter |
| `unlocked_letters_count` | int | Count of letters unlocked in writing practice |

### 4.6 Data Models

| Model | Location | Fields |
|-------|----------|--------|
| `ArabicLetterModel` | `Alphabet/data/models/` | `letter`, `word`, `emoji` |
| `LetterName` | `core/data/letter_names.dart` | `letter`, `name`, `nameWithDiacritics` |
| `LetterShapes` | `core/models/letter_shapes.dart` | `letter`, `isolated`, `initial`, `medial`, `final_`, `name`, `example` |
| `MathLevelModel` | `math/data/models/` | `level`, `title`, `description`, `numbers` |
| `MathNumberModel` | `math/data/models/` | `number`, `label` |
| `FinalTestModel` | `level_one/data/models/` | Test question structure |
| `RevisionTestModel` | `exercises/data/models/` | Revision test structure |
| `WordModel` | `word_training/models/` | Word training data |
| Level 2 models | `level_two/data/models/` | `ImageDescriptionModel`, `ImageNameModel`, `MissingWordModel`, `SentenceOrderModel`, `WordMatchModel`, `WordSpellingModel` |

### 4.7 Static Data
- `constants.dart` — `arabicLetters` list (28 `ArabicLetterModel`s), word lists
- `math_data.dart` — 3 `MathLevelModel`s (1-10, multiples of 10, 21-99)
- `ArabicLetterShapes.shapes` — 28 `LetterShapes` with all 4 positional forms

---

## 5. Audio & TTS System

### 5.1 AppTtsService (`core/audio/app_tts_service.dart`)
**Singleton:** `AppTtsService.instance`

**Architecture:**
- Uses `FlutterTts` for text-to-speech
- Generation-based cancellation system (no `Future.delayed` for TTS sync)
- Each call to `speakScreenIntro()` increments `_introGeneration`
- If navigation occurs before speech finishes, the old generation is stale and subsequent actions are skipped

**Key Methods:**
```dart
// Safe screen-entry narration (ALWAYS use this for screen intros)
Future<void> speakScreenIntro(String text, {required bool Function() isMounted})

// Direct TTS (for interactive button-press speech)
Future<void> speak(String text)

// Stop current speech
Future<void> stop()

// Warm up the TTS engine (called once in main.dart)
Future<void> warmUp()
```

**Critical Rules:**
- ❌ **NEVER** use `Future.delayed` to synchronize TTS with UI
- ✅ **ALWAYS** use `speakScreenIntro()` for any speech triggered on screen entry
- ✅ **ALWAYS** call `AppTtsService.instance.stop()` in `dispose()` and before navigation
- ✅ **ALWAYS** pass `isMounted: () => mounted` to `speakScreenIntro()`

### 5.2 TTS Configuration (`core/audio/tts_config.dart`)
```dart
class TtsConfig {
  static const String language = 'ar';
  static const double speechRate = 0.45;  // Slower for children
  static const double pitch = 1.0;
  static const double volume = 1.0;
}
```
- Auto-detects Android TTS engine (Google, Samsung, etc.)
- Falls back to device default if Arabic not supported
- Warm-up: `await tts.speak(' ')` to pre-initialize the engine

### 5.3 Audio Players
- **Package:** `audioplayers` (for sound effects)
- Used for correct/incorrect answer sounds, celebration audio
- Audio files stored in `assets/audio/`
- Assets include letter pronunciation audio files

### 5.4 Gemini AI Integration (`writing_practice/`)
**Status:** Experimental / commented-out (not active in production)

**Location:** `lib/features/writing_practice/presentation/views/widgets/gemini_test_view.dart`

**How it works (when enabled):**
1. Child writes a letter on a `SfSignaturePad` (from `syncfusion_flutter_signaturepad`)
2. The canvas is exported as a PNG image via `toImage()` → `toByteData(format: ui.ImageByteFormat.png)`
3. Image is sent to Gemini's vision model via `gemini.textAndImage()` with the prompt:
   ```
   هل الحرف في هذه الصورة هو الحرف العربي '<target>'? أجب بكلمة 'نعم' أو 'لا' فقط
   ```
4. Response is parsed for `'نعم'` (correct) or treated as incorrect

**Dependencies (for Gemini):**
- `google_generative_ai` — Google's Generative AI SDK
- `flutter_dotenv` — Loads API key from `.env` file
- `syncfusion_flutter_signaturepad` — Canvas for handwriting input

**Why it's commented out:** The feature was prototyped but not finalized for production. The entire `GeminiTestView` class is wrapped in `//` comments. To re-enable, uncomment the file and ensure the API key is set in `.env`.

**Active writing practice:** The production writing practice uses `WritingPracticeViewBody` with `SfSignaturePad` for freeform practice + `AutomatedLetterTraceScreen` for guided tracing, without Gemini.

### 5.5 Known Platform Issues
- **Samsung TTS:** May not support `ar` locale — config auto-detects and adjusts
- **Cold start lag:** Mitigated by TTS warm-up in `main.dart`
- **Stale audio on fast navigation:** Solved by generation-based cancellation in `AppTtsService`

---

## 6. SVG / Letter & Number Tracing

### 6.1 Letter Tracing Architecture
**Data flow:** SVG file → `rootBundle.loadString()` → XML parse → extract `<path d="...">` → `writeSvgPathDataToPath()` → Flutter `Path` object → custom `CustomPainter`

**Key classes:**
- `SvgPathConverter` — Converts SVG path strings to Flutter `Path`s
- `SvgLetterPathManager` — Singleton cache for loaded letter paths
- `SvgLetterTracingView` — The tracing canvas view
- `SvgLetterTracePainter` — Custom painter for rendering the tracing overlay

**SVG Assets:**
- Letters: `assets/svg/<letter>.svg` (28 files, one per Arabic letter)
- Numbers: `assets/svg/numbers/<number>.svg` (1-9, 10, 20, 30, …, 100)

### 6.2 Number Tracing
- `SvgNumberPathConverter` — Same pattern as letters but with canvas scaling
- `loadNumberFromSvg()` accepts `canvasWidth`, `canvasHeight`, `padding` for responsive layout
- Numbers are auto-scaled and centered on the canvas

### 6.3 Tracing UX
- Path displayed as a dotted/dashed guide
- User traces with finger on touch screen
- Progress tracked by proximity to path points
- Completion triggers celebration + progress update

### 6.4 Legacy Systems (still present but less used)
- `letter_paths.dart` — Hardcoded point-based paths (pre-SVG)
- `simple_svg_letter_paths.dart` — Simplified SVG paths
- `SimpleSvgLetterView` — Alternative tracing with simpler paths

---

## 7. Speech Recognition

### 7.1 Package
- **`speech_to_text`** — Platform speech recognition

### 7.2 Arabic Pronunciation Matching
The `NumberPronunciationPracticeView` demonstrates the canonical pattern:

**Pronunciation Map (for numbers with multiple valid pronunciations):**
```dart
static const Map<int, List<String>> _numberPronunciations = {
  2: ['اثنان', 'اثنين', 'اتنان', 'اتنين'],
  8: ['ثمانية', 'تمانية', 'ثمانيه', 'تمانيه'],
  9: ['تسعة', 'تسعه'],
  // ... etc.
};
```

**Text Normalization (`_normalizeWord`):**
1. Strip diacritics (fatha, damma, kasra, sukun, shadda, tanween)
2. Normalize hamza variants: `أ`, `إ`, `آ` → `ا`
3. Normalize taa marbuta: `ة` → `ه`
4. Remove whitespace

**Matching Flow:**
1. User speaks → STT returns Arabic text
2. Normalize the recognized text
3. Check each word in the result against the pronunciation map
4. Accept if ANY word matches ANY valid pronunciation

### 7.3 Letter Pronunciation
- `CharacterPronunciationPracticeView` — Speech recognition for individual letters
- Uses similar normalization but matches against letter names from `letter_names.dart`

---

## 8. Navigation Patterns

### 8.1 App Flow
```
WelcomeScreen → HomeSubjectSelection ─┬─→ LevelsSelection → LevelOne → [Letter Activities]
                                       │                   → LevelTwo → [Word Activities]
                                       └─→ MathView → MathLevelNumbers → MathNumberActivities → [Math Activities]
```

### 8.2 GoRouter vs Navigator.push
| Use Case | System | Example |
|----------|--------|---------|
| Top-level screen navigation | `context.push(AppRouter.kRoute)` | Home → Math |
| Going "home" (replacing stack) | `context.go(AppRouter.kRoute)` | Back to home |
| Sub-feature drill-down | `Navigator.push(context, AnimatedRoute.xxx(widget))` | Letter → Tracing |
| Test/quiz flows | `Navigator.push(context, AnimatedRoute.elegantZoom(widget))` | Revision test |

### 8.3 Transition Guidelines
- **Main screens:** `fadeScale` or `slideRight`
- **Tests/quizzes:** `elegantZoom`
- **Modal-like screens:** `slideUp`
- **Sub-feature views:** `AnimatedRoute.slideRight()` with `Navigator.push`

---

## 9. UI & Styling Conventions

### 9.1 Color System (`core/utils/app_colors.dart`)
```dart
AppColors.primaryGradient  // Main blue-purple gradient
AppColors.level1           // Level 1 gradient colors
AppColors.level2           // Level 2 gradient colors
AppColors.exercise1/2/3    // Exercise card gradients
AppColors.success          // Green for completed
AppColors.warning          // Orange for in-progress
AppColors.error            // Red for errors
AppColors.shadowLight/Medium/Dark  // Consistent shadow colors
```

### 9.2 Text Direction
- **All text is RTL (Arabic).** The app sets `locale: Locale('ar')` in `MaterialApp`
- `Directionality` is handled naturally by Flutter's RTL support

### 9.3 UI Patterns
- **Cards:** Rounded corners (`BorderRadius.circular(16-32)`), gradient backgrounds, box shadows
- **Lock/unlock states:** Locked items show `Icons.lock` + grey gradient; unlocked show full colors
- **Progress indicators:** `LinearProgressIndicator` with emoji labels (🌱→🌿→🌳→🌟)
- **Animations:** `AnimationController` + `FadeTransition`/`SlideTransition` on screen entry

### 9.4 Opacity Convention
- ✅ Use `color.withValues(alpha: 0.3)` (modern API)
- ❌ Do NOT use `color.withOpacity(0.3)` (deprecated)

---

## 10. Coding Conventions

### 10.1 Screen Entry Narration Pattern (MANDATORY)
Every screen that speaks on entry MUST follow this exact pattern:
```dart
class MyView extends StatefulWidget { ... }

class _MyViewState extends State<MyView> {
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _playIntroOnce();
  }

  Future<void> _playIntroOnce() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'Arabic narration text here',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }
}
```

### 10.2 Navigation Before TTS
Always stop TTS before navigating:
```dart
onTap: () {
  AppTtsService.instance.stop();
  context.push(AppRouter.kSomeRoute);
}
```

### 10.3 Progress Service Usage
```dart
// Level 1
final service = await UserProgressService.getInstance();
await service.completeActivity(letterIndex, activityIndex);

// Math
final service = await MathProgressService.getInstance();
await service.completeActivity(level, number, activityIndex);
```

### 10.4 File Naming
- Views: `*_view.dart`
- Widgets: `*_widget.dart` or descriptive names in `widgets/` folder
- Models: `*_model.dart`
- Services: `*_service.dart`
- Data files: descriptive names (e.g., `math_data.dart`, `svg_letter_paths.dart`)

### 10.5 Arabic Text
- All user-facing strings are hardcoded in Arabic (no localization framework)
- Comments in code are a mix of Arabic and English
- Letter/number data uses const lists and maps

### 10.6 Analysis
- Lint config: `package:flutter_lints/flutter.yaml`
- Target: **zero errors, zero warnings** from `dart analyze`

---

## 11. Dependencies (pubspec.yaml)

### Core
| Package | Purpose |
|---------|---------|
| `flutter_tts` | Text-to-speech for Arabic narration |
| `speech_to_text` | Speech recognition for pronunciation practice |
| `audioplayers` | Sound effects and audio playback |
| `hive` / `hive_flutter` | Local database for progress tracking |
| `shared_preferences` | Simple key-value storage |

### Navigation & UI
| Package | Purpose |
|---------|---------|
| `go_router` | Declarative routing |
| `google_fonts` | Typography (Tajawal, Cairo) |
| `flutter_svg` | SVG rendering |
| `lottie` | Animation files |

### SVG Tracing
| Package | Purpose |
|---------|---------|
| `xml` | SVG file parsing |
| `path_parsing` | SVG path data to Flutter Path conversion |

### Other
| Package | Purpose |
|---------|---------|
| `url_launcher` | Opening external links |
| `share_plus` | Share certificate/content |
| `confetti` | Celebration animations |
| `screenshot` | Certificate capture |
| `path_provider` | File system paths |
| `google_generative_ai` | Gemini AI integration (writing practice feedback) |
| `flutter_dotenv` | Environment variable management |

---

## 12. Asset Structure

```
assets/
├── svg/                  # SVG files for letter tracing
│   ├── ا.svg ... ي.svg   # 28 Arabic letter SVGs
│   └── numbers/          # Number SVGs for math tracing
│       ├── 1.svg - 9.svg
│       ├── 10.svg - 90.svg (by 10s)
│       ├── 100.svg
│       └── level1_Activity/
├── images/               # Letter/word images (Arabic filenames)
├── audio/                # Audio files for sounds
├── lottie/               # Lottie animation files
└── fonts/                # Custom fonts
```

---

## 13. Build & Release

### Version Pattern
- Format: `major.minor.patch+buildNumber` (e.g., `1.0.6+11`)
- Build number increments with each Play Store release

### Key Android Config
- `applicationId`: `com.baraa.arabiclearning`
- `minSdkVersion`: 23
- `targetSdkVersion`: 35
- `compileSdkVersion`: 35
- Signing: Uses `key.properties` for release keystore

### Build Commands
```bash
flutter build apk --release        # APK
flutter build appbundle --release   # AAB for Play Store
```

---

## 14. Gotchas & Known Issues

1. **`service_locator.dart` is empty** — DI is not used; services are singletons
2. **`assets_data.dart` has placeholder data** — All 28 entries point to the same image
3. **Two navigation systems coexist** — GoRouter for top-level, Navigator.push for sub-flows
4. **`LetterProgressService` uses SharedPreferences** while other services use Hive — historical inconsistency
5. **SVG letter paths have debug print statements** — `// ignore: avoid_print` annotations present
6. **Arabic text is hardcoded** — No l10n framework; all strings are inline Arabic
7. **`Alphabet` folder is capital-A** — Case-sensitive import paths: `features/Alphabet/...`
8. **Math Level 3 removes multiples of 10** — `..removeWhere((e) => e.number % 10 == 0)` in math_data.dart
9. **Not all features follow the full data/presentation split** — Some older feature folders are flat (no `data/` or `presentation/` subfolders). When creating new features, prefer the full structure, but don't assume existing features follow it.

---

## 15. How to Add New Content (Step-by-Step)

### 15.1 Adding a New Arabic Letter Activity (Level 1)

To add a new per-letter activity (e.g., Activity 5: "Letter Drawing"):

**Step 1: Create the activity view**
```
lib/features/level_one/presentation/views/my_new_activity_view.dart
  OR
lib/features/level_one/presentation/widgets/my_new_activity_widget.dart
```
- Extend `StatefulWidget`
- Accept the letter (or `ArabicLetterModel`) as a constructor parameter
- Follow the TTS screen-intro pattern (Section 10.1)
- On completion, call `onComplete` callback or return `true` via `Navigator.pop(context, true)`

**Step 2: Wire it into the letter-activities flow**
- Open the view that shows per-letter activities (e.g., `LetterShapesView`, or `level_one_view.dart`)
- Add your new activity to the navigation list/switch-case
- Use `AnimatedRoute.slideRight()` for forward navigation:
  ```dart
  await Navigator.push(context, AnimatedRoute.slideRight(MyNewActivityView(letter: letter)));
  ```

**Step 3: Track progress**
- Use `UserProgressService.getInstance()` and call:
  ```dart
  await service.completeActivity(letterIndex, NEW_ACTIVITY_INDEX);
  ```
- If the new activity is required for letter completion, update the unlock logic in `UserProgressService`

**Step 4: Run `dart analyze`** — Ensure zero errors

---

### 15.2 Adding a New Level 2 Word Activity Type

**Step 1: Create the data model**
```
lib/features/level_two/data/models/my_activity_model.dart
```
- Define the question/answer structure
- Add static data (word lists, images, etc.)

**Step 2: Create the activity view**
```
lib/features/level_two/presentation/views/my_activity_view.dart
```
- Follow the TTS screen-intro pattern (Section 10.1)
- On completion, call `Navigator.pop(context, true)` to signal success

**Step 3: (Optional) Create reusable widget**
```
lib/features/level_two/presentation/widgets/my_activity_widget.dart
```

**Step 4: Register in `LevelTwoView`**
- Open `lib/features/level_two/presentation/views/level_two_view.dart`
- Add an `ActivityItem` to the `_activities` list:
  ```dart
  ActivityItem(
    title: 'اسم النشاط',
    description: 'وصف النشاط',
    icon: Icons.some_icon,
    colors: AppColors.exercise3,  // Pick from AppColors.exercise1-5
  ),
  ```
- Add a case to `_getActivityView(int index)`:
  ```dart
  case 6: return const MyActivityView();
  ```
- **Important:** If the final test's index changes, update `_finalTestActivityIndex` constant

**Step 5: Update progress tracking**
- The `_openActivity` method auto-calls `completeLevel2Activity(activityIndex: index, totalActivities: _activities.length)`
- No extra progress code needed unless custom logic is required

---

### 15.3 Adding a New Math Number to an Existing Level

Numbers are auto-generated from `math_data.dart`:

**For Level 1 (1-10):** Already complete. To extend the range:
```dart
// In lib/features/math/data/math_data.dart
MathLevelModel(
  level: 1,
  title: 'المستوى الأول',
  description: 'الأرقام من ١ إلى ١٥',  // Update description
  numbers: List.generate(
    15,  // Change from 10 to 15
    (index) => MathNumberModel(
      number: index + 1,
      label: (index + 1).toArabicDigits(),
    ),
  ),
),
```

**For tracing support:** Add SVG files:
```
assets/svg/numbers/<number>.svg
```
Then register in `pubspec.yaml` under `flutter > assets` (if not already covered by a wildcard).

**For pronunciation support:** Add accepted pronunciations:
- Open `lib/features/math/presentation/views/number_pronunciation_practice_view.dart`
- Add entries to `_numberPronunciations` map:
  ```dart
  11: ['أحد عشر', 'احد عشر', 'حداشر'],
  ```

---

### 15.4 Registering a New GoRouter Route

**Step 1: Define the route constant** in `lib/core/utils/app_router.dart`:
```dart
static const String kMyNewView = '/myNewView';
```

**Step 2: Add the `GoRoute`** to the `routes` list in the same file:
```dart
GoRoute(
  path: kMyNewView,
  pageBuilder: (context, state) => PageTransitions.slideRight(
    child: const MyNewView(),
    state: state,
  ),
),
```

**Step 3: Choose the right transition:**
| Transition | Best for |
|------------|----------|
| `PageTransitions.fadeScale()` | Main/landing screens |
| `PageTransitions.slideRight()` | Forward navigation |
| `PageTransitions.slideUp()` | Modal-like / popup screens |
| `PageTransitions.elegantZoom()` | Tests, quizzes, special screens |
| `PageTransitions.fade()` | Simple/fast transitions |

**Step 4: Navigate to it:**
```dart
// Push (adds to stack):
context.push(AppRouter.kMyNewView);

// Go (replaces stack):
context.go(AppRouter.kMyNewView);
```

**When NOT to use GoRouter:** For sub-feature drill-downs (e.g., letter → activity), use `Navigator.push` with `AnimatedRoute` instead. GoRouter is for top-level screens only.

---

### 15.5 Creating a New Feature Folder

**Step 1: Create the folder structure:**
```
lib/features/my_feature/
├── data/
│   ├── models/
│   │   └── my_feature_model.dart      # Data models
│   └── my_feature_data.dart            # Static data / constants
└── presentation/
    ├── views/
    │   └── my_feature_view.dart         # Main screen
    └── widgets/
        └── my_feature_widget.dart       # Reusable sub-widgets
```

**Step 2: Create the main view** following conventions:
```dart
import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';

class MyFeatureView extends StatefulWidget {
  const MyFeatureView({super.key});

  @override
  State<MyFeatureView> createState() => _MyFeatureViewState();
}

class _MyFeatureViewState extends State<MyFeatureView> {
  bool _hasPlayedIntro = false;

  @override
  void initState() {
    super.initState();
    _playIntroOnce();
  }

  Future<void> _playIntroOnce() async {
    if (_hasPlayedIntro) return;
    _hasPlayedIntro = true;
    await AppTtsService.instance.speakScreenIntro(
      'وصف الشاشة بالعربية',
      isMounted: () => mounted,
    );
  }

  @override
  void dispose() {
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
          ),
        ),
        child: const SafeArea(
          child: Center(child: Text('محتوى الميزة')),
        ),
      ),
    );
  }
}
```

**Step 3: Register the route** (see Section 15.4)

**Step 4: Add navigation entry point** — Wire into the relevant parent screen (Home, Level view, etc.)

**Step 5: (If progress is needed)** — Either extend an existing service or create a new one following the Hive singleton pattern:
```dart
class MyFeatureService {
  static MyFeatureService? _instance;
  late Box _box;

  static Future<MyFeatureService> getInstance() async {
    if (_instance == null) {
      _instance = MyFeatureService();
      _instance!._box = Hive.box('myFeatureBox');
    }
    return _instance!;
  }
}
```
Don't forget to open the Hive box in `main.dart`:
```dart
await Hive.openBox('myFeatureBox');
```

**Step 6: Run `dart analyze`** — Must pass with zero issues

### Checklist for Any New Content
- [ ] TTS screen-intro pattern used (Section 10.1)
- [ ] `AppTtsService.instance.stop()` in `dispose()` and before navigation
- [ ] Colors from `AppColors`, not hardcoded
- [ ] `withValues(alpha:)` not `withOpacity()`
- [ ] Arabic UI text for all user-facing strings
- [ ] Progress tracked via appropriate service
- [ ] `dart analyze` passes with zero issues

---

## 16. Celebration & Animation Patterns

### 16.1 When to Use What

| Scenario | Tool | Usage |
|----------|------|-------|
| Activity/letter completion | `confetti` package | `ConfettiController` + `ConfettiWidget` overlay |
| Screen entry animation | `AnimationController` + `FadeTransition` / `SlideTransition` | In `initState`, duration ~600ms |
| Loading/idle states | `lottie` package | `Lottie.asset('assets/lottie/xxx.json')` |
| Number/score changes | `AnimatedSwitcher` + custom tween | Wrap the changing widget |

### 16.2 Confetti Pattern (MANDATORY for activity completion)
```dart
late ConfettiController _confettiController;

@override
void initState() {
  super.initState();
  _confettiController = ConfettiController(duration: const Duration(seconds: 2));
}

@override
void dispose() {
  _confettiController.dispose();
  super.dispose();
}

// On success:
void _onSuccess() {
  _confettiController.play();
  // Then update progress + navigate after delay
}

// In build():
Align(
  alignment: Alignment.topCenter,
  child: ConfettiWidget(
    confettiController: _confettiController,
    blastDirectionality: BlastDirectionality.explosive,
    colors: const [Colors.green, Colors.blue, Colors.orange, Colors.red],
  ),
)
```

### 16.3 Screen Entry Animation Pattern
```dart
late AnimationController _animController;
late Animation<double> _fadeAnim;

@override
void initState() {
  super.initState();
  _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  _animController.forward();
}

@override
void dispose() {
  _animController.dispose();
  super.dispose();
}

// In build():
FadeTransition(
  opacity: _fadeAnim,
  child: YourWidget(),
)
```
