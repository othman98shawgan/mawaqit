import 'package:flutter_test/flutter_test.dart';
import 'package:alfajr/models/prayer_alarm.dart';
import 'package:alfajr/services/prayer_alarm_service.dart';

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
  });
}
