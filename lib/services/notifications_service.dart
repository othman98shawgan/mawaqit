import 'dart:typed_data';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'store_manager.dart';

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

class NotificationsStatusNotifier with ChangeNotifier {
  bool _notificationsStatus = false;
  bool _notificationsAlreadyRequested = false;

  bool getNotificationsStatus() => _notificationsStatus;

  NotificationsStatusNotifier() {
    StorageManager.readData('NotificationsStatus').then((value) {
      _notificationsStatus = value ?? 10;
      notifyListeners();
    });
  }

  void setNotificationsOn() async {
    _notificationsStatus = true;
    StorageManager.saveData('NotificationsStatus', true);
    notifyListeners();
  }

  void setNotificationsOff() async {
    _notificationsStatus = false;
    StorageManager.saveData('NotificationsStatus', false);
    notifyListeners();
  }

  void requestNotification() async {
    if (_notificationsAlreadyRequested) {
      AppSettings.openNotificationSettings();
    }

    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
        _notificationsAlreadyRequested = true;
      }
    });
    await Permission.notification.isPermanentlyDenied.then((value) {
      if (value) {
        Permission.notification.request();
        _notificationsAlreadyRequested = true;
      }
    });
    await Permission.notification.isGranted.then((value) {
      if (!value) {
        setNotificationsOff();
      }
    });
    // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    //     FlutterLocalNotificationsPlugin();
    // flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    //     ?.requestPermission();
  }
}
