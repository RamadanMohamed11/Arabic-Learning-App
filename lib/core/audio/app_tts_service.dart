import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';

/// A global singleton TTS service that ensures only one voice plays at a time.
///
/// When any screen calls [speak], any currently playing speech is stopped first.
/// This eliminates audio overlap when navigating between screens.
///
/// Usage in any screen:
/// ```dart
/// // In initState or after a delay:
/// AppTtsService.instance.speak('Your Arabic text here');
///
/// // No need to stop manually in dispose — the next screen's speak() handles it.
/// // But you CAN stop explicitly if needed:
/// AppTtsService.instance.stop();
/// ```
class AppTtsService {
  AppTtsService._();

  static final AppTtsService instance = AppTtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  /// Configure the TTS engine (called once lazily on first speak).
  Future<void> _ensureConfigured({
    double speechRate = 0.4,
    double pitch = 1.0,
  }) async {
    if (!_configured) {
      await TtsConfig.configure(_tts, speechRate: speechRate, pitch: pitch);
      _configured = true;
    }
  }

  /// Stop any currently playing speech immediately.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('AppTtsService: Error stopping TTS: $e');
    }
  }

  /// Stop any current speech, then speak the given [text].
  ///
  /// Optionally provide [speechRate] and [pitch] to override the defaults
  /// for this particular utterance (they are applied once during initial
  /// configuration; subsequent calls use the already-configured engine).
  Future<void> speak(
    String text, {
    double speechRate = 0.4,
    double pitch = 1.0,
  }) async {
    await stop();
    await _ensureConfigured(speechRate: speechRate, pitch: pitch);
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('AppTtsService: Error speaking: $e');
    }
  }

  /// Set a callback for when speech completes.
  void setCompletionHandler(VoidCallback handler) {
    _tts.setCompletionHandler(handler);
  }

  /// Access the underlying FlutterTts instance for advanced use cases
  /// (e.g., speech-to-text coordination in the welcome screen).
  FlutterTts get rawTts => _tts;
}
