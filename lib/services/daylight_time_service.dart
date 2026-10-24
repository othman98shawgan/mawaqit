import 'package:flutter/material.dart';
import 'store_manager.dart';

class DaylightSavingNotifier with ChangeNotifier {
  final summer = true;

  bool _isAutoDst = true;
  bool _summerTime = isDstOnDate(DateTime.now());

  bool get isAutoDst => _isAutoDst;

  bool getSummerTime() {
    if (_isAutoDst) {
      _summerTime = isDstOnDate(DateTime.now());
    }
    return _summerTime;
  }

  DaylightSavingNotifier() {
    _initDst();
  }

  Future<void> _initDst() async {
    final savedAuto = await StorageManager.readData('isAutoDst');
    _isAutoDst = savedAuto is bool ? savedAuto : true;

    if (_isAutoDst) {
      _summerTime = isDstOnDate(DateTime.now());
      StorageManager.saveData('isSummer', _summerTime);
    } else {
      final savedIsSummer = await StorageManager.readData('isSummer');
      _summerTime = savedIsSummer is bool ? savedIsSummer : isDstOnDate(DateTime.now());
    }
    notifyListeners();
  }

  void setAutoDst(bool value) async {
    _isAutoDst = value;
    StorageManager.saveData('isAutoDst', value);
    if (_isAutoDst) {
      _summerTime = isDstOnDate(DateTime.now());
      StorageManager.saveData('isSummer', _summerTime);
    }
    notifyListeners();
  }

  /// Returns whether [date] is in Summer Time (DST).
  /// If [isAutoDst] is enabled, checks the official calendar schedule.
  /// If disabled, follows the user's manual preference.
  bool getSummerTimeForDate(DateTime date) {
    if (_isAutoDst) {
      return isDstOnDate(date);
    }
    return _summerTime;
  }

  void setSummerTime() async {
    _summerTime = true;
    StorageManager.saveData('isSummer', true);
    notifyListeners();
  }

  void setWinterTime() async {
    _summerTime = false;
    StorageManager.saveData('isSummer', false);
    notifyListeners();
  }

  void switchSummerTime() async {
    if (_summerTime) {
      setWinterTime();
    } else {
      setSummerTime();
    }
  }

  //=============================================================================
  // Automatic DST Calculation (Jerusalem / Israel Time Determination Law)
  // - Starts: Friday before the last Sunday of March at 02:00 AM
  // - Ends:   Last Sunday of October at 02:00 AM
  //=============================================================================

  /// Returns the last Sunday of [month] (where March = 3, October = 10, both have 31 days).
  static DateTime lastSundayOfMonth(int year, int month) {
    final lastDay = DateTime(year, month, 31);
    final daysToSubtract = lastDay.weekday == DateTime.sunday ? 0 : lastDay.weekday;
    return DateTime(year, month, 31 - daysToSubtract);
  }

  /// Date when Summer Time (DST) begins in [year]: Friday before the last Sunday of March.
  static DateTime dstStartDate(int year) {
    final lastSunday = lastSundayOfMonth(year, 3);
    return DateTime(year, 3, lastSunday.day - 2);
  }

  /// Date when Summer Time (DST) ends in [year]: Last Sunday of October.
  static DateTime dstEndDate(int year) {
    return lastSundayOfMonth(year, 10);
  }

  /// Returns true if prayers on [date] follow Summer Time (DST).
  static bool isDstOnDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = dstStartDate(day.year);
    final end = dstEndDate(day.year);
    return !day.isBefore(start) && day.isBefore(end);
  }

  /// Returns the evening notification time (20:00 / 8:00 PM) the day before
  /// the next upcoming DST transition, along with whether it transitions to Summer Time.
  static ({DateTime notificationTime, bool toSummerTime}) getNextDstTransitionEve(DateTime from) {
    final springStart = dstStartDate(from.year);
    final autumnEnd = dstEndDate(from.year);
    final nextSpringStart = dstStartDate(from.year + 1);

    final candidates = <({DateTime notificationTime, bool toSummerTime})>[
      (
        notificationTime: DateTime(springStart.year, springStart.month, springStart.day - 1, 20, 0),
        toSummerTime: true,
      ),
      (
        notificationTime: DateTime(autumnEnd.year, autumnEnd.month, autumnEnd.day - 1, 20, 0),
        toSummerTime: false,
      ),
      (
        notificationTime: DateTime(nextSpringStart.year, nextSpringStart.month, nextSpringStart.day - 1, 20, 0),
        toSummerTime: true,
      ),
    ];

    return candidates.firstWhere((c) => c.notificationTime.isAfter(from));
  }
}
