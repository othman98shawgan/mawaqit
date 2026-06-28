import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/store_manager.dart';

class NotificationsStatusNotifier with ChangeNotifier {
  late bool _notificationsStatus;
  bool _notificationsAlreadyRequested = false;

  bool getNotificationsStatus() => _notificationsStatus;

  NotificationsStatusNotifier() {
    StorageManager.readData('NotificationsStatus').then((value) {
      _notificationsStatus = value ?? false;
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
      AppSettings.openAppSettings(type: AppSettingsType.notification);
    }

    // Request basic notification permissions
    final status = await Permission.notification.request();
    
    // For Android 14+ we also explicitly need to request exact alarms permission via flutter_local_notifications
    if (Platform.isAndroid) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }

    _notificationsAlreadyRequested = true;

    if (status.isGranted) {
      setNotificationsOn();
    } else {
      setNotificationsOff();
    }
  }
}
