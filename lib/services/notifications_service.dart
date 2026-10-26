import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;

import 'package:alfajr/l10n/app_localizations.dart';
import 'store_manager.dart';

class NotificationsService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  static final Map<int, Timer> _windowsTimers = {};
  static final Map<int, PendingNotificationRequest> _windowsPendingRequests = {};
  static Future<void>? _initFuture;

  static Future<void> ensureInitialized() {
    _initFuture ??= init();
    return _initFuture!;
  }

  static Future<NotificationDetails> _notificationDetails(String channelId) async {
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 500;
    vibrationPattern[3] = 1000;

    final isArabic = (await StorageManager.readData('isArabic')) ?? true;
    final l10n = lookupAppLocalizations(Locale(isArabic ? 'ar' : 'en'));

    final String resolvedChannelId = channelId.contains('reminder')
        ? 'mawaqit_reminder_channel'
        : (channelId.contains('dst') ? 'mawaqit_dst_channel' : 'mawaqit_prayer_channel');

    final String channelName = channelId.contains('reminder')
        ? l10n.reminderNotificationChannelName
        : (channelId.contains('dst') ? l10n.dstNotificationChannelName : l10n.prayerNotificationChannelName);

    final String channelDescription = channelId.contains('reminder')
        ? l10n.reminderNotificationChannelDescription
        : (channelId.contains('dst') ? l10n.dstNotificationChannelDescription : l10n.prayerNotificationChannelDescription);

    return NotificationDetails(
      android: AndroidNotificationDetails(
        resolvedChannelId,
        channelName,
        channelDescription: channelDescription,
        icon: '@drawable/launcher_icon',
        playSound: true,
        enableVibration: true,
        importance: Importance.max,
        priority: Priority.high,
        vibrationPattern: vibrationPattern,
      ),
      windows: const WindowsNotificationDetails(),
    );
  }

  static Future cancelAll() async {
    await ensureInitialized();
    for (final timer in _windowsTimers.values) {
      timer.cancel();
    }
    _windowsTimers.clear();
    _windowsPendingRequests.clear();
    await _notifications.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await ensureInitialized();
    _windowsTimers[id]?.cancel();
    _windowsTimers.remove(id);
    _windowsPendingRequests.remove(id);
    await _notifications.cancel(id: id);
  }

  static Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    await ensureInitialized();
    List<PendingNotificationRequest> osPending = [];
    try {
      osPending = await _notifications.pendingNotificationRequests();
    } catch (_) {}

    if (_windowsPendingRequests.isEmpty) {
      return osPending;
    }

    final existingIds = osPending.map((e) => e.id).toSet();
    final combined = List<PendingNotificationRequest>.from(osPending);
    for (final req in _windowsPendingRequests.values) {
      if (!existingIds.contains(req.id)) {
        combined.add(req);
      }
    }
    return combined;
  }

  static Future<bool> canScheduleExactNotifications() async {
    if (!kIsWeb && Platform.isWindows) {
      return true;
    }
    final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return (await android?.canScheduleExactNotifications()) ?? false;
  }

  static Future<bool?> requestExactAlarmsPermission() async {
    if (!kIsWeb && Platform.isWindows) {
      return true;
    }
    final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestExactAlarmsPermission();
  }

  static Future init({bool initSheduled = false}) async {
    try {
      tz.initializeTimeZones();
      String timeZoneName = 'Asia/Jerusalem';
      try {
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone().timeout(
          const Duration(seconds: 2),
        );
        timeZoneName = timeZoneInfo.identifier;
      } catch (_) {}

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Asia/Jerusalem'));
      }
    } catch (_) {}

    try {
      const android = AndroidInitializationSettings('@drawable/launcher_icon');
      const windows = WindowsInitializationSettings(
        appName: 'Mawaqit Al-Quds',
        appUserModelId: 'com.othman.mawaqitquds',
        guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
      );
      const settings = InitializationSettings(
        android: android,
        windows: windows,
      );
      await _notifications.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          onNotifications.add(response.payload);
        },
      );
    } catch (_) {}
  }

  static Future showNotifications({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await ensureInitialized();
    return _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: await _notificationDetails(id.toString()),
      payload: payload,
    );
  }

  static Future<void> scheduleNotifications({
    int id = 0,
    required String channelId,
    String? title,
    String? body,
    String? payload,
    required DateTime sheduledDate,
  }) async {
    await ensureInitialized();

    final now = DateTime.now();
    if (!sheduledDate.isAfter(now)) {
      return;
    }

    final isoDate = sheduledDate.toIso8601String();
    final effectivePayload =
        (payload == null || payload.isEmpty) ? isoDate : (payload.contains(isoDate) ? payload : '$payload|$isoDate');

    final scheduledTzDate = tz.TZDateTime(
      tz.local,
      sheduledDate.year,
      sheduledDate.month,
      sheduledDate.day,
      sheduledDate.hour,
      sheduledDate.minute,
      sheduledDate.second,
    );

    if (!kIsWeb && Platform.isWindows) {
      _windowsTimers[id]?.cancel();
      _windowsPendingRequests[id] = PendingNotificationRequest(
        id,
        title,
        body,
        effectivePayload,
      );

      bool scheduledNatively = false;
      try {
        await _notifications.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledTzDate,
          notificationDetails: await _notificationDetails(channelId),
          payload: effectivePayload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        scheduledNatively = true;
      } catch (_) {
        scheduledNatively = false;
      }

      final duration = sheduledDate.difference(DateTime.now());
      if (!duration.isNegative) {
        _windowsTimers[id] = Timer(duration, () {
          _windowsTimers.remove(id);
          _windowsPendingRequests.remove(id);
          if (!scheduledNatively) {
            showNotifications(
              id: id,
              title: title,
              body: body,
              payload: effectivePayload,
            );
          }
        });
      }
      return;
    }

    try {
      final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final canExact = (await android?.canScheduleExactNotifications()) ?? true;
      final scheduleMode = canExact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;

      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTzDate,
        notificationDetails: await _notificationDetails(channelId),
        payload: effectivePayload,
        androidScheduleMode: scheduleMode,
      );
    } catch (e) {
      debugPrint("Error scheduling notification id $id: $e");
    }
  }
}

class NotificationsStatusNotifier with ChangeNotifier {
  bool _notificationsStatus;
  bool _notificationsAlreadyRequested = false;

  bool getNotificationsStatus() => _notificationsStatus;

  NotificationsStatusNotifier([bool initialStatus = true]) : _notificationsStatus = initialStatus {
    StorageManager.readData('NotificationsStatus').then((value) {
      if (value != null) {
        _notificationsStatus = value;
      }
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
    if (!kIsWeb && Platform.isWindows) {
      return;
    }
    if (_notificationsAlreadyRequested) {
      AppSettings.openAppSettings(type: AppSettingsType.notification);
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
  }
}
