import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationsService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails(String channelId) async {
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 500;
    vibrationPattern[3] = 1000;

    return NotificationDetails(
      android: AndroidNotificationDetails(channelId, 'channel name',
          channelDescription: 'channel description',
          importance: Importance.max,
          priority: Priority.high,
          vibrationPattern: vibrationPattern),
    );
  }

  static Future cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future init({bool initSheduled = false}) async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@drawable/launcher_icon');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings, onSelectNotification: (payload) async {
      onNotifications.add(payload);
    });
  }

  static Future showNotifications({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(id, title, body, await _notificationDetails(id.toString()),
          payload: payload);

  static void scheduleNotifications(
          {int id = 0,
          required String channelId,
          String? title,
          String? body,
          String? payload,
          required DateTime sheduledDate}) async =>
      _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(sheduledDate, tz.local),
        await _notificationDetails(channelId),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
}
