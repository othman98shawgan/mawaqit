import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:rxdart/rxdart.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;

class NotificationsService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future<NotificationDetails> _notificationDetails({
    required String channelId,
    required String channelName,
    required String channelDescription,
    String? soundName,
  }) async {
    var vibrationPattern = Int64List(6);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 500;
    vibrationPattern[3] = 1000;
    vibrationPattern[4] = 500;
    vibrationPattern[5] = 1000;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        vibrationPattern: vibrationPattern,
        // Optional: uncomment and add a custom sound file in android/app/src/main/res/raw/
        // sound: soundName != null ? RawResourceAndroidNotificationSound(soundName) : null,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        // Optional: uncomment and add a custom sound file in Xcode bundle
        // sound: soundName != null ? '$soundName.wav' : null,
      ),
    );
  }

  static Future cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future init({bool initSheduled = false}) async {
    // 1. Initialize timezones dynamically based on the device's actual timezone
    tz.initializeTimeZones();
    try {
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      // Fallback in case of failure
      tz.setLocalLocation(tz.UTC);
    }

    // 2. Configure Native Android and iOS Settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false, // Handled manually during onboarding
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        onNotifications.add(response.payload);
      },
    );
  }

  static Future showNotifications({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    String channelId = 'default_channel',
    String channelName = 'General Notifications',
    String channelDescription = 'App notifications',
    String? soundName,
  }) async => _notifications.show(
    id,
    title,
    body,
    await _notificationDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      soundName: soundName,
    ),
    payload: payload,
  );

  static void scheduleNotifications({
    int id = 0,
    required String channelId,
    String channelName = 'Scheduled Notifications',
    String channelDescription = 'Time-based reminders',
    String? title,
    String? body,
    String? payload,
    String? soundName,
    required DateTime scheduledDate,
  }) async => _notifications.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledDate, tz.local),
    await _notificationDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
      soundName: soundName,
    ),
    payload: payload,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}
