import 'dart:convert';
import 'dart:io';

import 'package:alfajr/models/prayers.dart';
import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/prayer_methods.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrayersModel & prayer-time.json validation', () {
    test('PrayersModel.empty initializes default times', () {
      final empty = PrayersModel.empty();
      expect(empty.date, '0.0');
      expect(empty.fajr, '00:00');
      expect(empty.isha, '00:00');
    });

    test('all entries in prayer-time.json parse cleanly with valid HH:MM format', () {
      final raw = File('lib/data/prayer-time.json').readAsStringSync();
      final decodedMap = json.decode(raw) as Map<String, dynamic>;
      final decoded = decodedMap['prayers'] as List<dynamic>;
      expect(decoded.length, greaterThanOrEqualTo(366));

      final timePattern = RegExp(r'^\d{1,2}:\d{2}$');
      for (int i = 0; i < decoded.length; i++) {
        final model = PrayersModel.fromJson(decoded[i] as Map<String, dynamic>);
        expect(model.date, isNotEmpty);
        expect(timePattern.hasMatch(model.fajr), isTrue, reason: 'Invalid fajr at $i');
        expect(timePattern.hasMatch(model.shuruq), isTrue, reason: 'Invalid shuruq at $i');
        expect(timePattern.hasMatch(model.duhr), isTrue, reason: 'Invalid duhr at $i');
        expect(timePattern.hasMatch(model.asr), isTrue, reason: 'Invalid asr at $i');
        expect(timePattern.hasMatch(model.maghrib), isTrue, reason: 'Invalid maghrib at $i');
        expect(timePattern.hasMatch(model.isha), isTrue, reason: 'Invalid isha at $i');
      }
    });
  });

  group('DaylightSavingNotifier DST schedule', () {
    test('lastSundayOfMonth returns correct Sunday for March and October 2026', () {
      final marchSunday = DaylightSavingNotifier.lastSundayOfMonth(2026, 3);
      expect(marchSunday, DateTime(2026, 3, 29));
      expect(marchSunday.weekday, DateTime.sunday);

      final octSunday = DaylightSavingNotifier.lastSundayOfMonth(2026, 10);
      expect(octSunday, DateTime(2026, 10, 25));
      expect(octSunday.weekday, DateTime.sunday);
    });

    test('isDstOnDate respects Friday before last Sunday of March to last Sunday of October', () {
      // 2026: DST starts Friday March 27, ends Sunday October 25
      expect(DaylightSavingNotifier.isDstOnDate(DateTime(2026, 3, 26)), isFalse);
      expect(DaylightSavingNotifier.isDstOnDate(DateTime(2026, 3, 27)), isTrue);
      expect(DaylightSavingNotifier.isDstOnDate(DateTime(2026, 7, 15)), isTrue);
      expect(DaylightSavingNotifier.isDstOnDate(DateTime(2026, 10, 24)), isTrue);
      expect(DaylightSavingNotifier.isDstOnDate(DateTime(2026, 10, 25)), isFalse);
    });

    test('getNextDstTransitionEve returns 20:00 the day before transition', () {
      final beforeSpring = DaylightSavingNotifier.getNextDstTransitionEve(DateTime(2026, 2, 1));
      expect(beforeSpring.toSummerTime, isTrue);
      expect(beforeSpring.notificationTime, DateTime(2026, 3, 26, 20, 0));

      final inSummer = DaylightSavingNotifier.getNextDstTransitionEve(DateTime(2026, 6, 1));
      expect(inSummer.toSummerTime, isFalse);
      expect(inSummer.notificationTime, DateTime(2026, 10, 24, 20, 0));
    });
  });

  group('getNextPrayer and getPrevPrayer', () {
    final raw = File('lib/data/prayer-time.json').readAsStringSync();
    final prayerList = (json.decode(raw) as Map<String, dynamic>)['prayers'] as List<dynamic>;
    final sampleDay = PrayersModel('1.1', '05:00', '06:30', '12:00', '15:00', '17:30', '19:00');

    test('returns correct next and previous prayer throughout the day without DST', () {
      final morning = DateTime(2026, 1, 15, 7, 0);
      final next = getNextPrayer(morning, sampleDay, false, 0, prayerList);
      final prev = getPrevPrayer(morning, sampleDay, false, 0, prayerList);
      expect(next.label, 'Duhr');
      expect(next.time, DateTime(2026, 1, 15, 12, 0));
      expect(prev.label, 'Shuruq');
      expect(prev.time, DateTime(2026, 1, 15, 6, 30));
    });

    test('applies +1 hour in summerTime and city timeDiff offset', () {
      final morning = DateTime(2026, 6, 15, 5, 30);
      final next = getNextPrayer(morning, sampleDay, true, 5, prayerList);
      expect(next.label, 'Fajr');
      // 05:00 + 1h + 5m = 06:05
      expect(next.time, DateTime(2026, 6, 15, 6, 5));
    });
  });
}
