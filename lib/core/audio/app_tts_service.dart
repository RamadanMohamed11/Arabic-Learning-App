import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:arabic_learning_app/core/audio/tts_config.dart';

/// A global singleton TTS service that ensures only one voice plays at a time.
///
/// When any screen calls [speak], any currently playing speech is stopped first.
/// This eliminates audio overlap when navigating between screens.
///
/// ## Screen-intro narration
///
/// Use [speakScreenIntro] for narration that should fire once when a screen
/// appears. It:
/// - cancels any previous pending intro (even from the screen below in the
///   navigator stack)
/// - waits a short time for the page-transition animation to finish
/// - checks a generation counter so that if the user navigated away (causing
///   another [stop] / [speak] / [speakScreenIntro]), the stale intro is
///   silently dropped.
///
/// ## Warming up
///
/// Call [warmUp] once during app startup (e.g. in `main()`) to
/// pre-configure the TTS engine.  This moves the expensive first-time
/// initialisation off the critical path of the first screen's intro speech.
class AppTtsService {
  AppTtsService._();

  static final AppTtsService instance = AppTtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;
  Future<void>? _configFuture;

  /// Monotonically increasing counter.  Every [stop], [speak], and
  /// [speakScreenIntro] call bumps this, which invalidates any pending
  /// delayed speech from an earlier call.
  int _generation = 0;

  /// Pre-configure the TTS engine so the first [speak] call is fast.
  /// Safe to call multiple times — the actual work runs only once.
  Future<void> warmUp({
    double speechRate = 0.4,
    double pitch = 1.0,
  }) async {
    await _ensureConfigured(speechRate: speechRate, pitch: pitch);
  }

  /// Configure the TTS engine (called once lazily on first speak).
  Future<void> _ensureConfigured({
    double speechRate = 0.4,
    double pitch = 1.0,
  }) async {
    if (_configured) return;
    if (_configFuture != null) {
      await _configFuture;
      if (_configured) return;
    }
    
    _configFuture = TtsConfig.configure(_tts, speechRate: speechRate, pitch: pitch);
    await _configFuture;
    _configured = true;
    _configFuture = null;
  }

  /// Stop any currently playing speech **and** invalidate any pending
  /// delayed intro speech so it will not fire later.
  Future<void> stop() async {
    _generation++; // invalidate pending delayed calls
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('AppTtsService: Error stopping TTS: $e');
    }
  }

  /// Stop any current speech, then speak the given [text].
  ///
  /// Also bumps the generation counter, so any pending delayed intros
  /// from a previous screen are invalidated.
  Future<void> speak(
    String text, {
    double speechRate = 0.4,
    double pitch = 1.0,
  }) async {
    _generation++; // invalidate any pending delayed speech
    try {
      await _tts.stop();
    } catch (_) {}
    await _ensureConfigured(speechRate: speechRate, pitch: pitch);
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('AppTtsService: Error speaking: $e');
    }
  }

  /// Speak a screen-entry intro message with built-in cancellation safety.
  ///
  /// - [delayMs]: how long to wait for the page-transition animation before
  ///   speaking.  Defaults to 150ms (enough for most transitions without
  ///   feeling laggy).
  /// - [isMounted]: callback that the caller uses to report whether the
  ///   widget is still mounted.  If the widget was disposed before the delay
  ///   expires, the speech is skipped.
  ///
  /// Returns silently if the generation changed (meaning another TTS call
  /// happened in the meantime, e.g. from a new screen).
  Future<void> speakScreenIntro(
    String text, {
    int delayMs = 150,
    required bool Function() isMounted,
    double speechRate = 0.4,
    double pitch = 1.0,
  }) async {
    _generation++;
    final myGeneration = _generation;

    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    // If another TTS call happened while we waited, bail out silently.
    if (_generation != myGeneration) return;
    if (!isMounted()) return;

    try {
      await _tts.stop();
    } catch (_) {}
    await _ensureConfigured(speechRate: speechRate, pitch: pitch);

    // Double-check after async gap
    if (_generation != myGeneration) return;
    if (!isMounted()) return;

    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('AppTtsService: Error speaking screen intro: $e');
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
