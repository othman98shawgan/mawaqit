import 'package:flutter_test/flutter_test.dart';
import 'package:alfajr/services/day_of_year_service.dart';

void main() {
  test('dayOfYear calculation test', () {
    final day = DateTime(2023, 1, 1);
    expect(dayOfYear(day), 0);
  });

  test('dayOfYear changes across midnight and year-end', () {
    final today = DateTime(2026, 11, 3, 23, 59, 59);
    final tomorrow = today.add(const Duration(seconds: 2));
    expect(dayOfYear(today) != dayOfYear(tomorrow), true);

    final dec31 = DateTime(2026, 12, 31, 23, 59, 59);
    final jan1 = dec31.add(const Duration(seconds: 2));
    expect(dayOfYear(dec31), 365);
    expect(dayOfYear(jan1), 0);
  });

  test('duration until midnight is positive and less than 24 hours', () {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now) + const Duration(seconds: 1);

    expect(durationUntilMidnight.isNegative, false);
    expect(durationUntilMidnight <= const Duration(hours: 24, seconds: 1), true);
  });
}
