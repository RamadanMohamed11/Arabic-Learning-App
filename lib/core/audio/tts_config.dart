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

    await _ensureAndroidEngine(tts);
    final selectedLanguage = await _resolveLanguage(tts, language);
    await tts.setLanguage(selectedLanguage);
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

  static Future<void> _ensureAndroidEngine(FlutterTts tts) async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final currentEngine = await tts.getDefaultEngine;
      final engines = await tts.getEngines;
      if (engines is! List) return;
      final googleEngine = engines.cast<String?>().firstWhere(
        (engine) => engine == 'com.google.android.tts',
        orElse: () => null,
      );
      if (googleEngine != null && currentEngine != googleEngine) {
        await tts.setEngine(googleEngine);
      }
    } catch (_) {
      debugPrint('TtsConfig: Unable to enforce Google TTS engine.');
    }
  }

  static Future<String> _resolveLanguage(
    FlutterTts tts,
    String preferred,
  ) async {
    try {
      if (await _isLanguageAvailable(tts, preferred)) {
        return preferred;
      }
      const fallbacks = ['ar-EG', 'ar', 'ar-001'];
      for (final code in fallbacks) {
        if (await _isLanguageAvailable(tts, code)) {
          debugPrint('TtsConfig: Using fallback voice "$code".');
          return code;
        }
      }
      final langs = await tts.getLanguages;
      if (langs is List && langs.isNotEmpty) {
        final fallback = langs.first.toString();
        debugPrint(
          'TtsConfig: Preferred Arabic voice missing. Using "$fallback".',
        );
        return fallback;
      }
    } catch (err) {
      debugPrint('TtsConfig: Language negotiation failed: $err');
    }
    return preferred;
  }

  static Future<bool> _isLanguageAvailable(
    FlutterTts tts,
    String language,
  ) async {
    try {
      final available = await tts.isLanguageAvailable(language);
      if (available is bool) return available;
      if (available == 1) return true;
    } catch (_) {
      // ignore
    }
    return false;
  }
}
