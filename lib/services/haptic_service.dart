import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HapticService {
  static const MethodChannel _channel = MethodChannel('com.othman.mawaqitquds/alarm');

  @visibleForTesting
  static void Function(String type)? debugOnVibrate;

  static Future<void> tap() => _vibrate(durationMs: 20, amplitude: 60, isHeavy: false);

  static Future<void> complete() => _vibrate(durationMs: 45, amplitude: 140, isHeavy: true);

  static Future<void> _vibrate({
    required int durationMs,
    required int amplitude,
    required bool isHeavy,
  }) async {
    if (debugOnVibrate != null) {
      debugOnVibrate!(isHeavy ? 'complete' : 'tap');
      return;
    }
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await _channel.invokeMethod('vibrate', {
          'durationMs': durationMs,
          'amplitude': amplitude,
        });
        return;
      } catch (_) {}
    }
    if (isHeavy) {
      await HapticFeedback.heavyImpact();
    } else {
      await HapticFeedback.lightImpact();
    }
  }
}
