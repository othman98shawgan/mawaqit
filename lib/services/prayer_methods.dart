import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer.dart';
import '../models/prayers.dart';
import 'day_of_year_service.dart';

void printSnackBar(String message, BuildContext context, {int durationInSeconds = 1}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: durationInSeconds),
  ));
}

Prayer getNextPrayer(DateTime time, PrayersModel today, bool summerTime, List prayerList) {
  DateTime fajr =
      DateTime(time.year, time.month, time.day, getHour(today.fajr), getMinute(today.fajr));
  DateTime shuruq =
      DateTime(time.year, time.month, time.day, getHour(today.shuruq), getMinute(today.shuruq));
  DateTime duhr =
      DateTime(time.year, time.month, time.day, getHour(today.duhr), getMinute(today.duhr));
  DateTime asr =
      DateTime(time.year, time.month, time.day, getHour(today.asr), getMinute(today.asr));
  DateTime maghrib =
      DateTime(time.year, time.month, time.day, getHour(today.maghrib), getMinute(today.maghrib));
  DateTime isha =
      DateTime(time.year, time.month, time.day, getHour(today.isha), getMinute(today.isha));
  if (summerTime) {
    fajr = fajr.add(const Duration(hours: 1));
    shuruq = shuruq.add(const Duration(hours: 1));
    duhr = duhr.add(const Duration(hours: 1));
    asr = asr.add(const Duration(hours: 1));
    maghrib = maghrib.add(const Duration(hours: 1));
    isha = isha.add(const Duration(hours: 1));
  }

  if (time.isBefore(fajr)) return Prayer("Fajr", fajr);
  if (time.isBefore(shuruq)) return Prayer("Shuruq", shuruq);
  if (time.isBefore(duhr)) return Prayer("Duhr", duhr);
  if (time.isBefore(asr)) return Prayer("Asr", asr);
  if (time.isBefore(maghrib)) return Prayer("Maghrib", maghrib);
  if (time.isBefore(isha)) return Prayer("Isha", isha);

  //after Isha
  DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
  var dayInYear = dayOfYear(tomorrow);

  PrayersModel tomorrowPrayers = PrayersModel.fromJson(prayerList[dayInYear + 1]);
  DateTime fajrTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
      getHour(tomorrowPrayers.fajr), getMinute(tomorrowPrayers.fajr));
  fajrTomorrow = summerTime ? fajrTomorrow.add(const Duration(hours: 1)) : fajrTomorrow;
  return Prayer("Fajr", fajrTomorrow);
}

Prayer getPrevPrayer(DateTime time, PrayersModel today, bool summerTime, List prayerList) {
  DateTime fajr =
      DateTime(time.year, time.month, time.day, getHour(today.fajr), getMinute(today.fajr));
  DateTime shuruq =
      DateTime(time.year, time.month, time.day, getHour(today.shuruq), getMinute(today.shuruq));
  DateTime duhr =
      DateTime(time.year, time.month, time.day, getHour(today.duhr), getMinute(today.duhr));
  DateTime asr =
      DateTime(time.year, time.month, time.day, getHour(today.asr), getMinute(today.asr));
  DateTime maghrib =
      DateTime(time.year, time.month, time.day, getHour(today.maghrib), getMinute(today.maghrib));
  DateTime isha =
      DateTime(time.year, time.month, time.day, getHour(today.isha), getMinute(today.isha));

  if (summerTime) {
    fajr = fajr.add(const Duration(hours: 1));
    shuruq = shuruq.add(const Duration(hours: 1));
    duhr = duhr.add(const Duration(hours: 1));
    asr = asr.add(const Duration(hours: 1));
    maghrib = maghrib.add(const Duration(hours: 1));
    isha = isha.add(const Duration(hours: 1));
  }

  if (time.isAfter(isha)) return Prayer("Isha", isha);
  if (time.isAfter(maghrib)) return Prayer("Maghrib", maghrib);
  if (time.isAfter(asr)) return Prayer("Asr", asr);
  if (time.isAfter(duhr)) return Prayer("Duhr", duhr);
  if (time.isAfter(shuruq)) return Prayer("Shuruq", shuruq);
  if (time.isAfter(fajr)) return Prayer("Fajr", fajr);

  //before Fajr
  DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
  var dayInYear = dayOfYear(yesterday);

  PrayersModel yesterdayPrayers = PrayersModel.fromJson(prayerList[dayInYear - 1]);

  DateTime ishaYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day,
      getHour(yesterdayPrayers.isha), getMinute(yesterdayPrayers.isha));
  ishaYesterday = summerTime ? ishaYesterday.add(const Duration(hours: 1)) : ishaYesterday;
  return Prayer("Isha", ishaYesterday);
}

int getHour(String time) {
  return int.parse(time.split(':')[0]);
}

int getMinute(String time) {
  return int.parse(time.split(':')[1]);
}

DateTime getDateFromId(String prayerId) {
  int year = int.parse(prayerId.substring(0, 4));
  int month = int.parse(prayerId.substring(4, 6));
  int day = int.parse(prayerId.substring(6, 8));
  int hour = int.parse(prayerId.substring(8, 10));
  int minute = int.parse(prayerId.substring(10, 12));
  DateTime time = DateTime(year, month, day, hour, minute);
  return time;
}

String getPrayerNotificationId(DateTime time) {
  return DateFormat('yyyyMMddkkmm').format(time);
}

bool removePassedPrayers(List<String> prayers) {
  List<String> toDelete = [];
  var removed = false;
  for (final prayer in prayers) {
    var time = getDateFromId(prayer);
    if (time.isBefore(DateTime.now())) {
      toDelete.add(prayer);
      removed = true;
    }
  }
  for (final element in toDelete) {
    prayers.remove(element);
  }
  return removed;
}

List<Prayer> getTodayPrayers(PrayersModel prayersToday, bool summerTime) {
  var time = DateTime.now();
  List<Prayer> today = [];
  DateTime fajr = DateTime(
      time.year, time.month, time.day, getHour(prayersToday.fajr), getMinute(prayersToday.fajr));
  DateTime shuruq = DateTime(time.year, time.month, time.day, getHour(prayersToday.shuruq),
      getMinute(prayersToday.shuruq));
  DateTime duhr = DateTime(
      time.year, time.month, time.day, getHour(prayersToday.duhr), getMinute(prayersToday.duhr));
  DateTime asr = DateTime(
      time.year, time.month, time.day, getHour(prayersToday.asr), getMinute(prayersToday.asr));
  DateTime maghrib = DateTime(time.year, time.month, time.day, getHour(prayersToday.maghrib),
      getMinute(prayersToday.maghrib));
  DateTime isha = DateTime(
      time.year, time.month, time.day, getHour(prayersToday.isha), getMinute(prayersToday.isha));

  if (summerTime) {
    fajr = fajr.add(const Duration(hours: 1));
    shuruq = shuruq.add(const Duration(hours: 1));
    duhr = duhr.add(const Duration(hours: 1));
    asr = asr.add(const Duration(hours: 1));
    maghrib = maghrib.add(const Duration(hours: 1));
    isha = isha.add(const Duration(hours: 1));
  }

  if (fajr.isAfter(time)) today.add(Prayer('Fajr', fajr));
  if (shuruq.isAfter(time)) today.add(Prayer('Shuruq', shuruq));
  if (duhr.isAfter(time)) today.add(Prayer('Duhr', duhr));
  if (asr.isAfter(time)) today.add(Prayer('Asr', asr));
  if (maghrib.isAfter(time)) today.add(Prayer('Maghrib', maghrib));
  if (isha.isAfter(time)) today.add(Prayer('Isha', isha));

  return today;
}

List<Prayer> getNextWeekPrayers(
    PrayersModel prayersToday, List prayerList, int dayInYear, bool summerTime) {
  List<Prayer> prayersList = [];

  var day1 = DateTime.now().add(const Duration(days: 1));
  var day2 = DateTime.now().add(const Duration(days: 2));
  var day3 = DateTime.now().add(const Duration(days: 3));
  var day4 = DateTime.now().add(const Duration(days: 4));
  var day5 = DateTime.now().add(const Duration(days: 5));
  var day6 = DateTime.now().add(const Duration(days: 6));

  prayersList.addAll(getDayPrayers(
      day1, prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day1)]), summerTime));
  prayersList.addAll(getDayPrayers(
      day2, prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day2)]), summerTime));
  prayersList.addAll(getDayPrayers(
      day3, prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day3)]), summerTime));
  prayersList.addAll(getDayPrayers(
      day4, prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day4)]), summerTime));
  prayersList.addAll(getDayPrayers(
      day5, prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day5)]), summerTime));
  prayersList.addAll(getDayPrayers(
      day6, prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day6)]), summerTime));

  return prayersList;
}

List<Prayer> getDayPrayers(DateTime day, PrayersModel prayers, bool summerTime) {
  var time = day;
  List<Prayer> prayersList = [];
  DateTime fajr =
      DateTime(time.year, time.month, time.day, getHour(prayers.fajr), getMinute(prayers.fajr));
  DateTime shuruq =
      DateTime(time.year, time.month, time.day, getHour(prayers.shuruq), getMinute(prayers.shuruq));
  DateTime duhr =
      DateTime(time.year, time.month, time.day, getHour(prayers.duhr), getMinute(prayers.duhr));
  DateTime asr =
      DateTime(time.year, time.month, time.day, getHour(prayers.asr), getMinute(prayers.asr));
  DateTime maghrib = DateTime(
      time.year, time.month, time.day, getHour(prayers.maghrib), getMinute(prayers.maghrib));
  DateTime isha =
      DateTime(time.year, time.month, time.day, getHour(prayers.isha), getMinute(prayers.isha));

  if (summerTime) {
    fajr = fajr.add(const Duration(hours: 1));
    shuruq = shuruq.add(const Duration(hours: 1));
    duhr = duhr.add(const Duration(hours: 1));
    asr = asr.add(const Duration(hours: 1));
    maghrib = maghrib.add(const Duration(hours: 1));
    isha = isha.add(const Duration(hours: 1));
  }

  prayersList.add(Prayer('Fajr', fajr));
  prayersList.add(Prayer('Shuruq', shuruq));
  prayersList.add(Prayer('Duhr', duhr));
  prayersList.add(Prayer('Asr', asr));
  prayersList.add(Prayer('Maghrib', maghrib));
  prayersList.add(Prayer('Isha', isha));

  return prayersList;
}

Future<List<String>> getScheduledPrayers() async {
  final prefs = await SharedPreferences.getInstance();
  final scheduledPrayers = prefs.getStringList('scheduledPrayers') ?? [];
  return scheduledPrayers;
}

Future<void> setScheduledPrayers(List<String> scheduledPrayers) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setStringList('scheduledPrayers', scheduledPrayers);
}
