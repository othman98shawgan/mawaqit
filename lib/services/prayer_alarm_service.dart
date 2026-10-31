import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

import '../data/prayer_times.dart';
import '../models/prayer.dart';
import '../models/prayer_alarm.dart';
import '../models/prayers.dart';
import 'day_of_year_service.dart';
import 'daylight_time_service.dart';
import 'notifications_service.dart';
import 'prayer_methods.dart';
import 'store_manager.dart';

@pragma('vm:entry-point')
void alarmActionBackgroundCallback(NotificationResponse response) async {
  final payload = response.payload ?? '';
  if (response.actionId == 'alarm_dismiss' || response.actionId == 'alarm_snooze') {
    final prayer = payload.startsWith('alarm|') ? payload.split('|')[1] : 'Fajr';
    if (response.actionId == 'alarm_dismiss') {
      await PrayerAlarmService.dismiss(prayer);
    } else if (response.actionId == 'alarm_snooze') {
      await PrayerAlarmService.snooze(prayer);
    }
  } else if (payload.startsWith('alarm|')) {
    await PrayerAlarmService.triggerAlarmNow(payload);
  }
}

class PrayerAlarmService {
  static const MethodChannel _alarmChannel = MethodChannel('com.othman.mawaqitquds/alarm');
  static final BehaviorSubject<String?> onNativeAlarmTriggered = BehaviorSubject<String?>();
  static bool _channelInitialized = false;

  static void initPlatformChannel() {
    if (_channelInitialized || kIsWeb || !Platform.isAndroid) return;
    _channelInitialized = true;
    _alarmChannel.setMethodCallHandler((call) async {
      if (call.method == 'onAlarmTriggered') {
        final payload = call.arguments as String?;
        if (payload != null) {
          onNativeAlarmTriggered.add(payload);
        }
      }
    });
  }

  static Future<bool> canUseFullScreenIntent() async {
    if (kIsWeb || !Platform.isAndroid) return true;
    try {
      final res = await _alarmChannel.invokeMethod<bool>('canUseFullScreenIntent');
      return res ?? true;
    } catch (e) {
      debugPrint('Error checking canUseFullScreenIntent: $e');
      return true;
    }
  }

  static Future<void> openFullScreenIntentSettings() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _alarmChannel.invokeMethod('openFullScreenIntentSettings');
    } catch (e) {
      debugPrint('Error opening full screen intent settings: $e');
    }
  }

  static Future<void> triggerAlarmNow(String payload) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _alarmChannel.invokeMethod('triggerAlarmNow', {'payload': payload});
    } catch (e) {
      debugPrint('Error triggering alarm now: $e');
    }
  }

  static Future<void> wakeScreen() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _alarmChannel.invokeMethod('wakeScreen');
    } catch (e) {
      debugPrint('Error waking screen: $e');
    }
  }

  static Future<void> startAlarmAudio(String soundName) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _alarmChannel.invokeMethod('startAlarmAudio', {'soundName': soundName});
    } catch (e) {
      debugPrint('Error starting alarm audio: $e');
    }
  }

  static Future<void> stopAlarmAudio() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _alarmChannel.invokeMethod('stopAlarmAudio');
    } catch (e) {
      debugPrint('Error stopping alarm audio: $e');
    }
  }

  static Future<String?> getPendingAlarmPayload() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      return await _alarmChannel.invokeMethod<String>('getPendingAlarmPayload');
    } catch (e) {
      debugPrint('Error getting pending alarm payload: $e');
      return null;
    }
  }

  static const String _prefsPrefix = 'PrayerAlarm_';
  static final Map<String, int> _alarmIds = {
    'Fajr': 810010,
    'Shuruq': 810020,
    'Duhr': 810030,
    'Asr': 810040,
    'Maghrib': 810050,
    'Isha': 810060,
  };
  static const int _snoozeBaseId = 810090;
  static const int testAlarmId = 810999;

  static AndroidNotificationSound? resolveSound(String soundType) {
    switch (soundType) {
      case 'alaqsa':
        return const RawResourceAndroidNotificationSound('adhan_alaqsa');
      case 'makkah':
        return const RawResourceAndroidNotificationSound('adhan_makkah');
      case 'madina':
        return const RawResourceAndroidNotificationSound('adhan_madina');
      case 'abdulbasit':
        return const RawResourceAndroidNotificationSound('adhan_abdulbasit');
      case 'minshawi':
        return const RawResourceAndroidNotificationSound('adhan_minshawi');
      case 'hussary':
        return const RawResourceAndroidNotificationSound('adhan_hussary');
      case 'nafees':
        return const RawResourceAndroidNotificationSound('adhan_nafees');
      case 'system':
      default:
        return null;
    }
  }

  static const Map<String, int> _prayerIndex = {
    'Fajr': 1,
    'Shuruq': 2,
    'Duhr': 3,
    'Asr': 4,
    'Maghrib': 5,
    'Isha': 6,
  };

  static int getPrayerAlarmId(String prayerName, DateTime prayerTime) {
    final day = dayOfYear(prayerTime);
    final pIndex = _prayerIndex[prayerName] ?? 1;
    return 800000 + (day * 10) + pIndex;
  }

  static int getAlarmId(String prayerName, [DateTime? date]) {
    if (date != null) {
      return getPrayerAlarmId(prayerName, date);
    }
    return _alarmIds[prayerName] ?? 810010;
  }

  static int getSnoozeAlarmId(String prayerName) {
    return _snoozeBaseId + (_alarmIds.keys.toList().indexOf(prayerName).clamp(0, 5));
  }

  static Future<PrayerAlarmSettings> loadAlarmSettings(String prayerName) async {
    final key = '$_prefsPrefix$prayerName';
    final raw = await StorageManager.readData(key);
    if (raw != null && raw is String && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as Map<String, dynamic>;
        return PrayerAlarmSettings.fromJson(decoded);
      } catch (e) {
        debugPrint('Error decoding alarm settings for $prayerName: $e');
      }
    }
    return PrayerAlarmSettings(prayerName: prayerName, isEnabled: false);
  }

  static Future<void> saveAlarmSettings(PrayerAlarmSettings settings) async {
    final key = '$_prefsPrefix${settings.prayerName}';
    final raw = json.encode(settings.toJson());
    await StorageManager.saveData(key, raw);
  }

  static Future<Map<String, PrayerAlarmSettings>> loadAllAlarmSettings() async {
    final Map<String, PrayerAlarmSettings> all = {};
    for (final prayer in _alarmIds.keys) {
      all[prayer] = await loadAlarmSettings(prayer);
    }
    return all;
  }

  static Future<bool> isBatteryOptimizationIgnored() async {
    if (!kIsWeb && Platform.isAndroid) {
      return await Permission.ignoreBatteryOptimizations.isGranted;
    }
    return true;
  }

  static Future<bool> requestIgnoreBatteryOptimization() async {
    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations.request();
      return status.isGranted;
    }
    return true;
  }

  static Future<void> cancelAlarm(String prayerName) async {
    if (kIsWeb || !Platform.isAndroid) return;
    final now = DateTime.now();
    for (int i = 0; i < 14; i++) {
      final date = now.add(Duration(days: i));
      final id = getPrayerAlarmId(prayerName, date);
      try {
        await _alarmChannel.invokeMethod('cancelNativeAlarm', {'id': id});
      } catch (_) {}
      await NotificationsService.cancelNotification(id);
    }
    final legacyId = _alarmIds[prayerName];
    if (legacyId != null) {
      try {
        await _alarmChannel.invokeMethod('cancelNativeAlarm', {'id': legacyId});
      } catch (_) {}
      await NotificationsService.cancelNotification(legacyId);
    }
    final snoozeId = getSnoozeAlarmId(prayerName);
    try {
      await _alarmChannel.invokeMethod('cancelNativeAlarm', {'id': snoozeId});
    } catch (_) {}
    await NotificationsService.cancelNotification(snoozeId);
  }

  static Future<void> scheduleUpcomingAlarms({
    List? prayerList,
    bool? summerTime,
    int? timeDiff,
    Map<String, String>? localizedTitles,
    Map<String, String>? localizedBodies,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;

    final alarmSettingsMap = await loadAllAlarmSettings();
    final enabledPrayers = alarmSettingsMap.entries.where((e) => e.value.isEnabled).map((e) => e.key).toSet();

    if (enabledPrayers.isEmpty) {
      for (final prayer in _alarmIds.keys) {
        await cancelAlarm(prayer);
      }
      return;
    }

    for (final prayer in _alarmIds.keys) {
      if (!enabledPrayers.contains(prayer)) {
        await cancelAlarm(prayer);
      }
    }

    List prayersData = prayerList ?? [];
    if (prayersData.isEmpty) {
      try {
        prayersData = json.decode(prayersJson) as List;
      } catch (e) {
        debugPrint('Error loading prayersJson for alarms: $e');
        return;
      }
    }

    final diff = timeDiff ?? (await StorageManager.readData('timeDiff') as int? ?? 0);
    final now = DateTime.now();
    final prayersToSchedule = <Prayer>[];

    // Build today and next 13 days of prayers (14-day rolling buffer)
    for (int dayOffset = 0; dayOffset <= 13; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      final dayDst = summerTime ?? DaylightSavingNotifier.isDstOnDate(targetDate);
      final dayIdx = dayOfYear(targetDate);
      if (dayIdx >= 0 && dayIdx < prayersData.length) {
        final dayPrayersModel = PrayersModel.fromJson(prayersData[dayIdx]);
        prayersToSchedule.addAll(getDayPrayers(targetDate, dayPrayersModel, dayDst, diff));
      }
    }

    for (final prayer in prayersToSchedule) {
      if (!enabledPrayers.contains(prayer.label)) continue;
      final settings = alarmSettingsMap[prayer.label]!;

      final targetTime = prayer.time.add(Duration(minutes: settings.offsetMinutes));
      if (!targetTime.isAfter(now)) continue;

      final alarmId = getPrayerAlarmId(prayer.label, prayer.time);
      final alarmTitle = localizedTitles?[prayer.label] ?? '${prayer.label} Alarm';
      final alarmBody = localizedBodies?[prayer.label] ??
          (settings.offsetMinutes == 0
              ? 'Time for ${prayer.label}'
              : '${settings.offsetMinutes.abs()} minutes remaining until ${prayer.label}');

      try {
        await _alarmChannel.invokeMethod('scheduleNativeAlarm', {
          'id': alarmId,
          'triggerAtMillis': targetTime.millisecondsSinceEpoch,
          'prayerName': prayer.label,
          'soundName': settings.soundType,
          'title': alarmTitle,
          'body': alarmBody,
          'dismissLabel': 'Dismiss',
          'snoozeLabel': 'Snooze',
          'snoozeMinutes': settings.snoozeMinutes,
          'offsetMinutes': settings.offsetMinutes,
          'vibrate': settings.vibrate,
        });
      } catch (e) {
        debugPrint('Error scheduling rolling native alarm for ${prayer.label}: $e');
      }
    }
  }

  static Future<void> schedulePrayerAlarm({
    required String prayerName,
    required DateTime prayerTime,
    PrayerAlarmSettings? settings,
    String? title,
    String? body,
    String? dismissLabel,
    String? snoozeLabel,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;

    final config = settings ?? await loadAlarmSettings(prayerName);
    if (!config.isEnabled) {
      await cancelAlarm(prayerName);
      return;
    }

    DateTime targetTime = prayerTime.add(Duration(minutes: config.offsetMinutes));
    final now = DateTime.now();
    if (!targetTime.isAfter(now)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }

    final id = getAlarmId(prayerName);
    final alarmTitle = title ?? '$prayerName Alarm';
    final alarmBody = body ??
        (config.offsetMinutes == 0
            ? 'Time for $prayerName'
            : '${config.offsetMinutes.abs()} minutes remaining until $prayerName');

    try {
      await _alarmChannel.invokeMethod('scheduleNativeAlarm', {
        'id': id,
        'triggerAtMillis': targetTime.millisecondsSinceEpoch,
        'prayerName': prayerName,
        'soundName': config.soundType,
        'title': alarmTitle,
        'body': alarmBody,
        'dismissLabel': dismissLabel ?? 'Dismiss',
        'snoozeLabel': snoozeLabel ?? 'Snooze',
        'snoozeMinutes': config.snoozeMinutes,
        'offsetMinutes': config.offsetMinutes,
        'vibrate': config.vibrate,
      });
    } catch (e) {
      debugPrint('Error scheduling native prayer alarm ($prayerName): $e');
    }
  }

  static Future<void> snooze(
    String prayerName, {
    int? snoozeMinutes,
    String? soundType,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    await stopAlarmAudio();

    final config = await loadAlarmSettings(prayerName);
    final duration = snoozeMinutes ?? (config.snoozeMinutes > 0 ? config.snoozeMinutes : 5);
    final sound = soundType ?? config.soundType;
    final snoozeTime = DateTime.now().add(Duration(minutes: duration));
    final snoozeId = getSnoozeAlarmId(prayerName);

    try {
      await _alarmChannel.invokeMethod('scheduleNativeAlarm', {
        'id': snoozeId,
        'triggerAtMillis': snoozeTime.millisecondsSinceEpoch,
        'prayerName': prayerName.startsWith('Snooze:') ? prayerName : 'Snooze: $prayerName',
        'soundName': sound,
        'title': 'Snooze: $prayerName',
        'body': 'Alarm snoozed for $duration minutes',
        'dismissLabel': 'Dismiss',
        'snoozeLabel': 'Snooze',
        'snoozeMinutes': duration,
        'offsetMinutes': 0,
        'vibrate': config.vibrate,
      });
    } catch (e) {
      debugPrint('Error scheduling native snooze alarm ($prayerName): $e');
    }
  }

  static Future<void> scheduleTestAlarm({
    required String soundType,
    int delaySeconds = 5,
    int snoozeMinutes = 5,
    String? title,
    String? body,
    String? dismissLabel,
    String? snoozeLabel,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    final testTime = DateTime.now().add(Duration(seconds: delaySeconds));

    try {
      await _alarmChannel.invokeMethod('scheduleNativeAlarm', {
        'id': testAlarmId,
        'triggerAtMillis': testTime.millisecondsSinceEpoch,
        'prayerName': 'Test',
        'soundName': soundType,
        'title': title ?? 'Test Prayer Alarm',
        'body': body ?? 'Testing alarm audio ($soundType)',
        'dismissLabel': dismissLabel ?? 'Dismiss',
        'snoozeLabel': snoozeLabel ?? 'Snooze',
        'snoozeMinutes': snoozeMinutes,
        'offsetMinutes': 0,
        'vibrate': true,
      });
    } catch (e) {
      debugPrint('Error scheduling native test alarm: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getScheduledNativeAlarms() async {
    if (kIsWeb || !Platform.isAndroid) return [];
    try {
      final res = await _alarmChannel.invokeMethod('getScheduledNativeAlarms');
      if (res is List) {
        return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('Error getting scheduled native alarms: $e');
    }
    return [];
  }

  static Future<void> cancelSpecificAlarm(int id) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _alarmChannel.invokeMethod('cancelNativeAlarm', {'id': id});
      await NotificationsService.cancelNotification(id);
    } catch (e) {
      debugPrint('Error cancelling specific native alarm ($id): $e');
    }
  }

  static Future<void> dismiss(String prayerName) async {
    if (kIsWeb || !Platform.isAndroid) return;
    await stopAlarmAudio();
    final alarmId = getAlarmId(prayerName);
    final snoozeId = getSnoozeAlarmId(prayerName);
    try {
      await _alarmChannel.invokeMethod('cancelNativeAlarm', {'id': snoozeId});
      await _alarmChannel.invokeMethod('cancelNativeAlarm', {'id': testAlarmId});
    } catch (e) {
      debugPrint('Error dismissing native alarm: $e');
    }
    await NotificationsService.cancelNotification(alarmId);
    await NotificationsService.cancelNotification(snoozeId);
    await NotificationsService.cancelNotification(testAlarmId);
  }
}
