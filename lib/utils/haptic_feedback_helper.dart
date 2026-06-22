import 'package:flutter/services.dart';

/// Helper class to provide consistent haptic feedback sensations for interactions.
class HapticFeedbackHelper {
  /// Triggers a success vibration (medium/light bounce).
  static Future<void> success() async {
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Ignore exceptions on platforms without haptic engines (e.g. web/emulator)
    }
  }

  /// Triggers a warning/error vibration (heavy shake impact).
  static Future<void> failure() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {
      // Ignore exceptions on platforms without haptic engines
    }
  }

  /// Light click/tap vibration.
  static Future<void> click() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {
      // Ignore exceptions on platforms without haptic engines
    }
  }
}
