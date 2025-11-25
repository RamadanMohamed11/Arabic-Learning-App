# Web TTS Audio Fix - Complete Solution

## Date
2025-11-25

## Problem Summary
The website build (Flutter Web) was experiencing multiple audio playback issues:
1. Sound sometimes cannot be played
2. App sometimes says random and strange words
3. Sometimes no sound plays at all
4. Error snackbar appears: "حدث خطأ في تشغيل الصوت يرجى المحاولة مرة أخرى"
5. "إعادة تهيئة الصوت" button appears

## Root Causes

### 1. Web Speech Synthesis Voice Loading
- Browser's Web Speech Synthesis API loads voices asynchronously
- Previous timeout (2 seconds) was too short for some browsers
- No verification that Arabic voices were actually loaded

### 2. Voice Selection Issues
- No priority system for Arabic voice variants
- Could select wrong voice causing "random words" issue
- No fallback logic for high-quality Arabic voices

### 3. Completion Handler Configuration
- `awaitSpeakCompletion(false)` for web caused state management issues
- Callbacks not firing properly, leading to stuck "playing" state
- No proper error propagation from web TTS

### 4. User Feedback
- Generic error messages didn't help users understand web-specific issues
- No retry action in error snackbar
- Missing platform-specific guidance

## Solutions Implemented

### 1. Enhanced TtsConfig (lib/core/audio/tts_config.dart)

#### Voice Loading Timeout Increased
```dart
const int maxTries = 50; // ~5 seconds (was 20 / ~2 seconds)
```
- Increased timeout from 2 seconds to 5 seconds
- Gives browsers more time to load available voices
- Especially helpful for slower connections or initial page loads

#### Better Arabic Voice Selection
```dart
static Map<String, dynamic> _findBestArabicVoice(
  List<Map<String, dynamic>> voices,
) {
  // Priority order: ar-SA, ar-EG, ar-AE, ar-*
  const preferredLocales = ['ar-sa', 'ar-eg', 'ar-ae'];
  
  // First, try to find voices with preferred locales
  for (final preferredLocale in preferredLocales) {
    final voice = voices.firstWhere((voice) {
      final lang = _voiceLocaleOrLang(voice).toLowerCase();
      return lang == preferredLocale || lang.startsWith('$preferredLocale-');
    }, orElse: () => <String, dynamic>{});
    
    if (voice.isNotEmpty) {
      return voice;
    }
  }
  
  // If no preferred locale found, find any Arabic voice
  final arabicVoice = voices.firstWhere((voice) {
    final lang = _voiceLocaleOrLang(voice).toLowerCase();
    final name = (voice['name']?.toString() ?? '').toLowerCase();
    return lang.startsWith('ar') || name.contains('arabic');
  }, orElse: () => <String, dynamic>{});
  
  return arabicVoice;
}
```
- Prioritizes Saudi (ar-SA), Egyptian (ar-EG), and UAE (ar-AE) voices
- Ensures consistent, high-quality Arabic pronunciation
- Prevents "random words" by selecting correct voice variant
- Falls back to any Arabic voice if preferred not available

#### Fixed Completion Handler
```dart
// Set to true for better state management and callbacks
await tts.awaitSpeakCompletion(true);
```
- Changed from `false` to `true` for web
- Ensures callbacks fire properly
- Prevents stuck "playing" state
- Improves error handling

#### Better Error Handling
```dart
if (voices.isEmpty) {
  debugPrint(
    'TtsConfig: WARNING - No voices loaded from browser. Audio may not work.',
  );
}

// ...

if (arabicVoice.isEmpty) {
  debugPrint(
    'TtsConfig: WARNING - No Arabic voice found. Will use default voice.',
  );
}

// ...

} catch (err) {
  debugPrint('TtsConfig: Web configuration failed: $err');
  rethrow; // Propagate error for better handling
}
```
- Logs warnings when voices not available
- Rethrows errors for upstream handling
- Better debugging information

### 2. Enhanced PlacementTestViewBody (lib/features/placement_test/presentation/views/widgets/placement_test_view_body.dart)

#### Platform-Specific Error Messages
```dart
String errorMessage = 'حدث خطأ في تشغيل الصوت. يرجى المحاولة مرة أخرى.';

// Add web-specific hint
if (kIsWeb) {
  errorMessage = 'حدث خطأ في تشغيل الصوت. تأكد من السماح بالصوت في المتصفح.';
}
```
- Provides web-specific guidance
- Helps users understand browser permission requirements
- More actionable error messages

#### Retry Action in Snackbar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(errorMessage),
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
      label: 'إعادة المحاولة',
      onPressed: () => _playAudio(text),
    ),
  ),
);
```
- Adds retry button to error snackbar
- Users can immediately retry without navigating
- More user-friendly error recovery

#### Cleaned Up Logging
- Removed redundant language logging
- Kept essential debug information
- Cleaner console output

## Testing Recommendations

### Web Browsers
1. **Chrome/Edge (Chromium)**:
   - Test on latest version
   - Verify Arabic voices load within 5 seconds
   - Test speech synthesis permissions

2. **Firefox**:
   - Test voice selection
   - Verify completion callbacks work
   - Check Arabic pronunciation quality

3. **Safari** (if applicable):
   - May have different voice availability
   - Test voice loading timeout
   - Verify Arabic support

### Test Scenarios

1. **First Load**:
   - Open app in fresh browser session
   - Start placement test
   - Click "استمع للصوت" immediately
   - Verify audio plays in Arabic (not random language)

2. **Multiple Plays**:
   - Play audio 10 times in sequence
   - Verify same Arabic word each time
   - No random or strange words
   - No stuck "playing" state

3. **Error Recovery**:
   - Test with browser lacking Arabic voices
   - Verify clear error message appears
   - Test retry button functionality
   - Verify "إعادة تهيئة الصوت" works

4. **Network Conditions**:
   - Test on slow connection
   - Verify 5-second timeout sufficient
   - Check voice loading completes

## Expected Results After Fix

✅ Audio plays reliably on web builds  
✅ Consistent Arabic pronunciation (no random words)  
✅ Proper error messages for web users  
✅ Retry functionality in error snackbar  
✅ Better voice loading with 5-second timeout  
✅ Prioritized high-quality Arabic voices (Saudi, Egyptian, UAE)  
✅ Proper state management with awaitSpeakCompletion(true)  
✅ Clear debugging information in console  

## Files Modified

1. `lib/core/audio/tts_config.dart`
   - Increased voice loading timeout
   - Added `_findBestArabicVoice()` helper
   - Fixed `awaitSpeakCompletion` for web
   - Improved error handling and logging

2. `lib/features/placement_test/presentation/views/widgets/placement_test_view_body.dart`
   - Added `kIsWeb` import
   - Platform-specific error messages
   - Retry action in error snackbar
   - Cleaned up logging

## Browser Compatibility

| Browser | Arabic Voices | Expected Quality |
|---------|---------------|------------------|
| Chrome | ✅ Excellent | Google Arabic voices |
| Edge | ✅ Excellent | Microsoft Arabic voices |
| Firefox | ✅ Good | eSpeak Arabic voices |
| Safari | ⚠️ Varies | System voices (macOS/iOS) |

## Known Limitations

1. **Voice Availability**: Depends on browser and OS
2. **First Interaction**: Some browsers require user gesture before audio
3. **Offline**: Web Speech Synthesis may require internet on some browsers
4. **Quality Variance**: Voice quality varies by browser

## Future Improvements

- [ ] Add voice download prompt if no Arabic voices available
- [ ] Implement audio file fallback for critical words
- [ ] Add voice quality preference setting
- [ ] Implement speech rate adjustment per voice
- [ ] Add comprehensive browser compatibility check on app start
