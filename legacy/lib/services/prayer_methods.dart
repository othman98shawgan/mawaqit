import 'package:alfajr/services/locale_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/prayer.dart';
import '../models/prayers.dart';
import 'day_of_year_service.dart';
import 'daylight_time_service.dart';

void printSnackBar(String message, BuildContext context, {int durationInSeconds = 1}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: durationInSeconds),
  ));
}

Prayer getNextPrayer(
    DateTime time, PrayersModel today, bool summerTime, int timeDiff, List prayerList) {
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

  if (timeDiff != 0) {
    fajr = fajr.add(Duration(minutes: timeDiff));
    shuruq = shuruq.add(Duration(minutes: timeDiff));
    duhr = duhr.add(Duration(minutes: timeDiff));
    asr = asr.add(Duration(minutes: timeDiff));
    maghrib = maghrib.add(Duration(minutes: timeDiff));
    isha = isha.add(Duration(minutes: timeDiff));
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
  fajrTomorrow = fajrTomorrow.add(Duration(minutes: timeDiff));
  return Prayer("Fajr", fajrTomorrow);
}

Prayer getPrevPrayer(
    DateTime time, PrayersModel today, bool summerTime, int timeDiff, List prayerList) {
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

  if (timeDiff != 0) {
    fajr = fajr.add(Duration(minutes: timeDiff));
    shuruq = shuruq.add(Duration(minutes: timeDiff));
    duhr = duhr.add(Duration(minutes: timeDiff));
    asr = asr.add(Duration(minutes: timeDiff));
    maghrib = maghrib.add(Duration(minutes: timeDiff));
    isha = isha.add(Duration(minutes: timeDiff));
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
  ishaYesterday = ishaYesterday.add(Duration(minutes: timeDiff));
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

List<Prayer> getTodayPrayers(PrayersModel prayersToday, bool summerTime, int timeDiff) {
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

  if (timeDiff != 0) {
    fajr = fajr.add(Duration(minutes: timeDiff));
    shuruq = shuruq.add(Duration(minutes: timeDiff));
    duhr = duhr.add(Duration(minutes: timeDiff));
    asr = asr.add(Duration(minutes: timeDiff));
    maghrib = maghrib.add(Duration(minutes: timeDiff));
    isha = isha.add(Duration(minutes: timeDiff));
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
    PrayersModel prayersToday, List prayerList, int dayInYear, bool summerTime, int timeDiff) {
  List<Prayer> prayersList = [];

  var day1 = DateTime.now().add(const Duration(days: 1));
  var day2 = DateTime.now().add(const Duration(days: 2));
  var day3 = DateTime.now().add(const Duration(days: 3));
  var day4 = DateTime.now().add(const Duration(days: 4));
  var day5 = DateTime.now().add(const Duration(days: 5));
  var day6 = DateTime.now().add(const Duration(days: 6));

  prayersList.addAll(getDayPrayers(day1,
      prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day1)]), summerTime, timeDiff));
  prayersList.addAll(getDayPrayers(day2,
      prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day2)]), summerTime, timeDiff));
  prayersList.addAll(getDayPrayers(day3,
      prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day3)]), summerTime, timeDiff));
  prayersList.addAll(getDayPrayers(day4,
      prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day4)]), summerTime, timeDiff));
  prayersList.addAll(getDayPrayers(day5,
      prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day5)]), summerTime, timeDiff));
  prayersList.addAll(getDayPrayers(day6,
      prayersToday = PrayersModel.fromJson(prayerList[dayOfYear(day6)]), summerTime, timeDiff));

  return prayersList;
}

List<Prayer> getDayPrayers(DateTime day, PrayersModel prayers, bool summerTime, int timeDiff) {
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

  if (timeDiff != 0) {
    fajr = fajr.add(Duration(minutes: timeDiff));
    shuruq = shuruq.add(Duration(minutes: timeDiff));
    duhr = duhr.add(Duration(minutes: timeDiff));
    asr = asr.add(Duration(minutes: timeDiff));
    maghrib = maghrib.add(Duration(minutes: timeDiff));
    isha = isha.add(Duration(minutes: timeDiff));
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

String getPrayerTranslation(String label, BuildContext context) {
  var map = {
    'Fajr': AppLocalizations.of(context)!.fajrString,
    'Shuruq': AppLocalizations.of(context)!.shuruqString,
    'Duhr': AppLocalizations.of(context)!.duhrString,
    'Asr': AppLocalizations.of(context)!.asrString,
    'Maghrib': AppLocalizations.of(context)!.maghribString,
    'Isha': AppLocalizations.of(context)!.ishaString,
  };
  return map[label]!;
}

String adjustTime(BuildContext context, String time) {
  var currTimeDiff = Provider.of<LocaleNotifier>(context, listen: false).timeDiff;
  var summerTime = Provider.of<DaylightSavingNotifier>(context, listen: false).summer;
  if (!summerTime && currTimeDiff == 0) return time;
  int hour = int.parse(time.split(':')[0]);
  int minute = int.parse(time.split(':')[1]);
  var today = DateTime.now();
  var dateTime = DateTime(today.year, today.month, today.day, hour, minute);
  dateTime = dateTime.add(Duration(hours: 1, minutes: currTimeDiff));
  time = "${dateTime.hour.toString()}:${dateTime.minute.toString().padLeft(2, '0')}";
  return time;
}

sharePrayerTimes(BuildContext context, LocaleNotifier localeNotifier, PrayersModel prayersToday,DateTime date) {
  var locale = localeNotifier.locale;
  var localization = AppLocalizations.of(context)!;

  var title = localization.shareMessageTitle;  
  var day = DateFormat('EEEE', locale.toString()).format(date);
  var dateFormatted = DateFormat('dd/MM/yyyy').format(date);
  var fajrPryaer = '${localization.fajrString} - ${adjustTime(context, prayersToday.fajr)}';
  var shuruqPryaer = '${localization.shuruqString} - ${adjustTime(context, prayersToday.shuruq)}';
  var duhrPryaer = '${localization.duhrString} - ${adjustTime(context, prayersToday.duhr)}';
  var asrPryaer = '${localization.asrString} - ${adjustTime(context, prayersToday.asr)}';
  var maghribPryaer =
      '${localization.maghribString} - ${adjustTime(context, prayersToday.maghrib)}';
  var ishaPryaer = '${localization.ishaString} - ${adjustTime(context, prayersToday.isha)}';
  var downloadApp = localization.shareMessageDownload;
  var downloadLink = 'https://bit.ly/mawaqitquds';
  var newLine = '\n';
  var space = ' ';
  var dash = ' - ';
  Share.share(title +
      space +
      day +
      space +
      dateFormatted +
      newLine +
      newLine +
      fajrPryaer +
      newLine +
      shuruqPryaer +
      newLine +
      duhrPryaer +
      newLine +
      asrPryaer +
      newLine +
      maghribPryaer +
      newLine +
      ishaPryaer +
      newLine +
      newLine +
      downloadApp +
      dash +
      downloadLink);
}
