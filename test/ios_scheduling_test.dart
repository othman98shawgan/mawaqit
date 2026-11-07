import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfajr/data/prayer_times.dart';
import 'package:alfajr/models/prayers.dart';
import 'package:alfajr/services/day_of_year_service.dart';
import 'package:alfajr/services/prayer_methods.dart';

void main() {
  group('iOS Notification Scheduling Tests', () {
    test('getNextWeekPrayers with daysCount=4 respects 4-day cap for iOS', () {
      final data = json.decode(prayersJson) as List;
      final now = DateTime.now();
      final dayInYear = dayOfYear(now);
      final prayersToday = PrayersModel.fromJson(data[dayInYear]);

      final prayers4Days = getNextWeekPrayers(
        prayersToday,
        data,
        dayInYear,
        false,
        0,
        isAutoMode: false,
        daysCount: 4,
      );

      // 4 days * 6 prayers = 24 prayers
      expect(prayers4Days.length, 24);

      // Total notifications with reminders (each prayer + reminder = 2 notifications):
      // 24 * 2 = 48. Adding today's max remaining (6 * 2 = 12) + 1 DST = 61 <= 64 limit.
      const int maxRemainingToday = 6;
      final int totalPossibleNotifications = (prayers4Days.length + maxRemainingToday) * 2 + 1;
      expect(totalPossibleNotifications <= 64, isTrue);
    });

    test('getNextWeekPrayers default daysCount=6 remains standard for Android/Desktop', () {
      final data = json.decode(prayersJson) as List;
      final now = DateTime.now();
      final dayInYear = dayOfYear(now);
      final prayersToday = PrayersModel.fromJson(data[dayInYear]);

      final prayers6Days = getNextWeekPrayers(
        prayersToday,
        data,
        dayInYear,
        false,
        0,
        isAutoMode: false,
      );

      // 6 days * 6 prayers = 36 prayers
      expect(prayers6Days.length, 36);
    });
  });
}
