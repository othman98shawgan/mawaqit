import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alfajr/l10n/app_localizations.dart';
import 'package:alfajr/models/prayer_alarm.dart';
import 'package:alfajr/services/prayer_alarm_service.dart';
import 'package:alfajr/ui/alarm_ringing_page.dart';

void main() {
  group('PrayerAlarmSettings tests', () {
    test('Default values', () {
      const settings = PrayerAlarmSettings(prayerName: 'Fajr');
      expect(settings.prayerName, 'Fajr');
      expect(settings.isEnabled, false);
      expect(settings.offsetMinutes, 0);
      expect(settings.soundType, 'alaqsa');
      expect(settings.snoozeMinutes, 10);
      expect(settings.vibrate, true);
    });

    test('toJson and fromJson serialization', () {
      const original = PrayerAlarmSettings(
        prayerName: 'Asr',
        isEnabled: true,
        offsetMinutes: -20,
        soundType: 'minshawi',
        snoozeMinutes: 5,
        vibrate: false,
      );

      final json = original.toJson();
      final restored = PrayerAlarmSettings.fromJson(json);

      expect(restored.prayerName, 'Asr');
      expect(restored.isEnabled, true);
      expect(restored.offsetMinutes, -20);
      expect(restored.soundType, 'minshawi');
      expect(restored.snoozeMinutes, 5);
      expect(restored.vibrate, false);
    });

    test('copyWith works correctly', () {
      const original = PrayerAlarmSettings(prayerName: 'Fajr');
      final modified = original.copyWith(
        isEnabled: true,
        offsetMinutes: -15,
        soundType: 'makkah',
      );

      expect(modified.prayerName, 'Fajr');
      expect(modified.isEnabled, true);
      expect(modified.offsetMinutes, -15);
      expect(modified.soundType, 'makkah');
      expect(modified.snoozeMinutes, 10);
    });

    test('resolveSound maps sounds correctly', () {
      expect(PrayerAlarmService.resolveSound('alaqsa'), isNotNull);
      expect(PrayerAlarmService.resolveSound('makkah'), isNotNull);
      expect(PrayerAlarmService.resolveSound('madina'), isNotNull);
      expect(PrayerAlarmService.resolveSound('abdulbasit'), isNotNull);
      expect(PrayerAlarmService.resolveSound('minshawi'), isNotNull);
      expect(PrayerAlarmService.resolveSound('hussary'), isNotNull);
      expect(PrayerAlarmService.resolveSound('nafees'), isNotNull);
      expect(PrayerAlarmService.resolveSound('system'), isNull);
      expect(PrayerAlarmService.resolveSound('silent'), isNull);
    });

    test('Prayer alarm IDs are distinct and consistent', () {
      final fajrId = PrayerAlarmService.getAlarmId('Fajr');
      final duhrId = PrayerAlarmService.getAlarmId('Duhr');
      final ishaId = PrayerAlarmService.getAlarmId('Isha');

      expect(fajrId, isNot(equals(duhrId)));
      expect(duhrId, isNot(equals(ishaId)));

      final fajrSnoozeId = PrayerAlarmService.getSnoozeAlarmId('Fajr');
      expect(fajrId, isNot(equals(fajrSnoozeId)));

      final monday = DateTime(2026, 11, 1, 5, 0);
      final tuesday = DateTime(2026, 11, 2, 5, 0);
      final mondayFajr = PrayerAlarmService.getPrayerAlarmId('Fajr', monday);
      final mondayDuhr = PrayerAlarmService.getPrayerAlarmId('Duhr', monday);
      final tuesdayFajr = PrayerAlarmService.getPrayerAlarmId('Fajr', tuesday);

      expect(mondayFajr, isNot(equals(mondayDuhr)));
      expect(mondayFajr, isNot(equals(tuesdayFajr)));
      expect(PrayerAlarmService.getPrayerAlarmId('Fajr', monday), equals(mondayFajr));
    });

    test('5-minute precision offsets and target calculation', () {
      final prayerTime = DateTime(2026, 11, 1, 5, 0);
      for (int minutes = 0; minutes <= 60; minutes += 5) {
        final offset = minutes == 0 ? 0 : -minutes;
        final settings = PrayerAlarmSettings(prayerName: 'Fajr', offsetMinutes: offset);
        final target = prayerTime.add(Duration(minutes: settings.offsetMinutes));
        expect(target, equals(prayerTime.subtract(Duration(minutes: minutes))));
      }
    });

    testWidgets('AlarmRingingPage renders in silent mode when isAutoStopped is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: AlarmRingingPage(
            prayerName: 'Fajr',
            soundType: 'alaqsa',
            snoozeMinutes: 10,
            offsetMinutes: 0,
            isAutoStopped: true,
          ),
        ),
      );
      await tester.pump();

      final l10n = AppLocalizations.of(tester.element(find.byType(AlarmRingingPage)))!;
      expect(find.text(l10n.soundSilent), findsOneWidget);
      expect(find.byIcon(Icons.vibration), findsWidgets);
      expect(find.text(l10n.alarmSnooze), findsOneWidget);
      expect(find.text(l10n.alarmDismiss), findsOneWidget);
    });

    testWidgets('AlarmRingingPage pops automatically when onNativeAlarmAutoStopped emits',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AlarmRingingPage(
                        prayerName: 'Fajr',
                        soundType: 'alaqsa',
                        snoozeMinutes: 10,
                        offsetMinutes: 0,
                      ),
                    ),
                  );
                },
                child: const Text('Open Alarm'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Alarm'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(AlarmRingingPage), findsOneWidget);

      PrayerAlarmService.onNativeAlarmAutoStopped.add('Fajr');
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(AlarmRingingPage), findsNothing);
      expect(find.text('Open Alarm'), findsOneWidget);
    });

    test('alertMode and per-prayer reminder serialization + legacy compatibility', () {
      final legacyAlarm = PrayerAlarmSettings.fromJson({
        'prayerName': 'Fajr',
        'isEnabled': true,
        'offsetMinutes': -15,
        'soundType': 'makkah',
      });
      expect(legacyAlarm.alertMode, PrayerAlarmSettings.modeAlarm);
      expect(legacyAlarm.isAlarm, true);
      expect(legacyAlarm.isEnabled, true);
      expect(legacyAlarm.reminderEnabled, false);

      final legacyOff = PrayerAlarmSettings.fromJson({
        'prayerName': 'Duhr',
        'isEnabled': false,
      });
      expect(legacyOff.alertMode, PrayerAlarmSettings.modeOff);
      expect(legacyOff.isOff, true);
      expect(legacyOff.isEnabled, false);

      const notifWithReminder = PrayerAlarmSettings(
        prayerName: 'Asr',
        alertMode: PrayerAlarmSettings.modeNotification,
        reminderEnabled: true,
        reminderMinutes: 15,
      );
      expect(notifWithReminder.isNotification, true);
      expect(notifWithReminder.isEnabled, false);
      expect(notifWithReminder.isAlertActive, true);

      final roundTripped = PrayerAlarmSettings.fromJson(notifWithReminder.toJson());
      expect(roundTripped.alertMode, PrayerAlarmSettings.modeNotification);
      expect(roundTripped.reminderEnabled, true);
      expect(roundTripped.reminderMinutes, 15);
    });

    test('migrateLegacyAlertsIfNeeded preserves alarms, migrates notifications and reminders', () async {
      SharedPreferences.setMockInitialValues({
        'NotificationsStatus': true,
        'ReminderStatus': true,
        'Reminder': 15,
        'PrayerAlarm_Fajr': json.encode({
          'prayerName': 'Fajr',
          'isEnabled': true,
          'offsetMinutes': -10,
          'soundType': 'makkah',
          'snoozeMinutes': 5,
          'vibrate': true,
        }),
      });

      await PrayerAlarmService.migrateLegacyAlertsIfNeeded();
      final all = await PrayerAlarmService.loadAllAlarmSettings();

      expect(all['Fajr']!.alertMode, PrayerAlarmSettings.modeAlarm);
      expect(all['Fajr']!.soundType, 'makkah');
      expect(all['Fajr']!.offsetMinutes, -10);
      expect(all['Fajr']!.reminderEnabled, true);
      expect(all['Fajr']!.reminderMinutes, 15);

      expect(all['Duhr']!.alertMode, PrayerAlarmSettings.modeNotification);
      expect(all['Duhr']!.reminderEnabled, true);
      expect(all['Duhr']!.reminderMinutes, 15);

      // Idempotent on subsequent call even if user later changes a prayer to off
      await PrayerAlarmService.saveAlarmSettings(
        all['Duhr']!.copyWith(alertMode: PrayerAlarmSettings.modeOff),
      );
      await PrayerAlarmService.migrateLegacyAlertsIfNeeded();
      final duhrAfter = await PrayerAlarmService.loadAlarmSettings('Duhr');
      expect(duhrAfter.alertMode, PrayerAlarmSettings.modeOff);
    });
  });
}
