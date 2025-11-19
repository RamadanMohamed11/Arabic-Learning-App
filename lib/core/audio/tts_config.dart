import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Centralizes FlutterTts configuration so every screen requests the same
/// audio focus and voice characteristics. This helps release builds keep
/// playback working even when system policies are stricter than debug mode.
class TtsConfig {
  const TtsConfig._();

  static Future<void> configure(
    FlutterTts tts, {
    String language = 'ar-SA',
    double speechRate = 0.45,
    double pitch = 1.0,
    double volume = 1.0,
    bool awaitCompletion = true,
  }) async {
    if (awaitCompletion) {
      await tts.awaitSpeakCompletion(true);
    }
    await tts.setLanguage(language);
    await tts.setSpeechRate(speechRate);
    await tts.setPitch(pitch);
    await tts.setVolume(volume);
    await _applyAndroidAttributes(tts);
  }

  static Future<void> _applyAndroidAttributes(FlutterTts tts) async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await tts.setAudioAttributesForNavigation();
  }
}
