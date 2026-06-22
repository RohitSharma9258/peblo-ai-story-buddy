import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Abstract definition of the Text-to-Speech service to separate concerns.
abstract class TtsService {
  Future<void> init();
  Future<void> speak(String text);
  Future<void> stop();
  void setCallbacks({
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required ValueChanged<String> onError,
  });
  Future<void> dispose();
}

/// Concrete implementation of [TtsService] using the `flutter_tts` package.
class AppTtsService implements TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  
  VoidCallback? _onStart;
  VoidCallback? _onComplete;
  ValueChanged<String>? _onError;
  
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Configure TTS parameters appropriate for children
      await _flutterTts.setLanguage("en-US");
      // 0.4 to 0.48 speech rate is friendly and slow enough for comprehension by children (5-10)
      await _flutterTts.setSpeechRate(0.45);
      // Slightly higher pitch (1.1 - 1.25) makes the voice sound like a cute/friendly robot
      await _flutterTts.setPitch(1.15);
      await _flutterTts.setVolume(1.0);

      // Handle TTS Engine callbacks
      _flutterTts.setStartHandler(() {
        if (kDebugMode) print("TTS started successfully.");
        _onStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        if (kDebugMode) print("TTS completed successfully.");
        _onComplete?.call();
      });

      _flutterTts.setCancelHandler(() {
        if (kDebugMode) print("TTS cancelled/stopped.");
        _onComplete?.call(); // Treat cancel as completion/stop to release state
      });

      _flutterTts.setErrorHandler((message) {
        if (kDebugMode) print("TTS Error: $message");
        _onError?.call(message.toString());
      });

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) print("Failed to initialize TTS Service: $e");
      _onError?.call("Could not initialize Speech Engine: $e");
    }
  }

  @override
  void setCallbacks({
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required ValueChanged<String> onError,
  }) {
    _onStart = onStart;
    _onComplete = onComplete;
    _onError = onError;
  }

  @override
  Future<void> speak(String text) async {
    try {
      await init();
      if (text.isEmpty) {
        _onError?.call("The story text is empty!");
        return;
      }
      final result = await _flutterTts.speak(text);
      if (result == 0) {
        _onError?.call("TTS failed to start playback.");
      }
    } catch (e) {
      _onError?.call("TTS playback failed: $e");
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      if (kDebugMode) print("Error while stopping TTS: $e");
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await stop();
    } finally {
      _onStart = null;
      _onComplete = null;
      _onError = null;
    }
  }
}
