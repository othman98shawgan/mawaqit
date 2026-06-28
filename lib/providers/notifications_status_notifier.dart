import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsStatusNotifier extends ChangeNotifier {
  bool _isAllowed = false;
  bool get isAllowed => _isAllowed;

  // 1. FIXED: Initialize state immediately upon creation
  NotificationsStatusNotifier() {
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;

      // FIXED: The correct method name is canScheduleExactNotifications()
      final androidPlugin = FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final canScheduleExact = await androidPlugin?.canScheduleExactNotifications() ?? false;

      _isAllowed = status.isGranted && canScheduleExact;
    } else if (Platform.isIOS) {
      final status = await Permission.notification.status;
      _isAllowed = status.isGranted;
    }

    notifyListeners();
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android: Request standard notifications
      await Permission.notification.request();

      // Android 14+: Request exact alarm permission via native plugin implementation
      // This will redirect the user to the native system settings toggle page
      await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      // iOS: Request alert, badge, and sound via native plugin implementation
      await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // FIXED: Instead of guessing the outcome, run the unified verification check
    await checkPermissions();
  }
}
