import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_alarm.dart';
import 'notifications_service.dart';
import 'store_manager.dart';

@pragma('vm:entry-point')
void alarmActionBackgroundCallback(NotificationResponse response) async {
  if (response.actionId == 'alarm_dismiss' || response.actionId == 'alarm_snooze') {
    final payload = response.payload ?? '';
    final prayer = payload.startsWith('alarm|') ? payload.split('|')[1] : 'Fajr';
    if (response.actionId == 'alarm_dismiss') {
      await PrayerAlarmService.dismiss(prayer);
    } else if (response.actionId == 'alarm_snooze') {
      await PrayerAlarmService.snooze(prayer);
    }
  }
}

class PrayerAlarmService {
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
      case 'chime':
        return const RawResourceAndroidNotificationSound('alarm_chime');
      case 'system':
      default:
        return null;
    }
  }

  static int getAlarmId(String prayerName) {
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
    await NotificationsService.cancelNotification(getAlarmId(prayerName));
    await NotificationsService.cancelNotification(getSnoozeAlarmId(prayerName));
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
    final channelId = 'mawaqit_alarm_${config.soundType}';
    final channelName = 'Prayer Alarm (${config.soundType})';

    final sound = resolveSound(config.soundType);

    final vibrationPattern = Int64List(6);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 500;
    vibrationPattern[3] = 1000;
    vibrationPattern[4] = 500;
    vibrationPattern[5] = 1000;

    final actions = <AndroidNotificationAction>[
      AndroidNotificationAction(
        'alarm_dismiss',
        dismissLabel ?? 'Dismiss',
        cancelNotification: true,
      ),
    ];

    if (config.snoozeMinutes > 0) {
      actions.add(
        AndroidNotificationAction(
          'alarm_snooze',
          snoozeLabel ?? 'Snooze',
        ),
      );
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'High-priority prayer alarms that wake device and loop until stopped',
      icon: '@drawable/launcher_icon',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      sound: sound,
      enableVibration: config.vibrate,
      vibrationPattern: config.vibrate ? vibrationPattern : null,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      additionalFlags: Int32List.fromList(<int>[4]), // FLAG_INSISTENT: loops audio until handled
      actions: actions,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);
    final tzTarget = tz.TZDateTime.from(targetTime, tz.local);

    try {
      await NotificationsService.notificationsPlugin.zonedSchedule(
        id: id,
        title: title ?? 'Time for $prayerName',
        body: body ?? '',
        scheduledDate: tzTarget,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: 'alarm|$prayerName',
      );
    } catch (e) {
      debugPrint('Error scheduling prayer alarm ($prayerName): $e');
    }
  }

  static Future<void> snooze(String prayerName) async {
    if (kIsWeb || !Platform.isAndroid) return;
    await NotificationsService.cancelNotification(getAlarmId(prayerName));

    final config = await loadAlarmSettings(prayerName);
    final snoozeMinutes = config.snoozeMinutes > 0 ? config.snoozeMinutes : 10;
    final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMinutes));

    final sound = resolveSound(config.soundType);

    final androidDetails = AndroidNotificationDetails(
      'mawaqit_alarm_${config.soundType}',
      'Prayer Alarm (${config.soundType})',
      channelDescription: 'High-priority prayer alarms that wake device and loop until stopped',
      icon: '@drawable/launcher_icon',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      sound: sound,
      enableVibration: config.vibrate,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      additionalFlags: Int32List.fromList(<int>[4]),
      actions: [
        const AndroidNotificationAction(
          'alarm_dismiss',
          'Dismiss',
          cancelNotification: true,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);
    final tzTarget = tz.TZDateTime.from(snoozeTime, tz.local);

    try {
      await NotificationsService.notificationsPlugin.zonedSchedule(
        id: getSnoozeAlarmId(prayerName),
        title: 'Snooze: $prayerName',
        body: 'Alarm snoozed for $snoozeMinutes minutes',
        scheduledDate: tzTarget,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: 'alarm|$prayerName',
      );
    } catch (e) {
      debugPrint('Error scheduling snooze alarm ($prayerName): $e');
    }
  }

  static Future<void> dismiss(String prayerName) async {
    if (kIsWeb || !Platform.isAndroid) return;
    await NotificationsService.cancelNotification(getAlarmId(prayerName));
    await NotificationsService.cancelNotification(getSnoozeAlarmId(prayerName));
  }
}
