import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import '../models/prayer.dart';
import '../prayer_times.dart';
import '../models/prayers.dart';
import '../services/notifications_service.dart';
import 'widgets/card_widget.dart';
import 'widgets/clock_widget.dart';
import 'widgets/prayer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool summerTime = false;
  List _prayerList = [];
  int dayInYear = 0;

  Future<bool> getSummerTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isSummer = prefs.getBool('isSummer') ?? false;
    return isSummer;
  }

  Future<void> setSummerTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isSummer = prefs.getBool('isSummer') ?? false;
    prefs.setBool('isSummer', !isSummer);
  }

  String toSummerTime(String time) {
    if (!summerTime) return time;
    int hour = int.parse(time.split(':')[0]);
    int minute = int.parse(time.split(':')[1]);
    hour++;
    time = "$hour:$minute";
    return time;
  }

  Prayer getNextPrayer(DateTime time) {
    PrayersModel today = PrayersModel.fromJson(_prayerList[dayInYear]);

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
    PrayersModel tomorrowPrayers =
        PrayersModel.fromJson(_prayerList[dayInYear + 1]); //TODO: fix if last day of year.
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    DateTime fajrTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
        getHour(tomorrowPrayers.fajr), getMinute(tomorrowPrayers.fajr));
    fajrTomorrow = summerTime ? fajrTomorrow.add(const Duration(hours: 1)) : fajrTomorrow;
    return Prayer("Fajr", fajrTomorrow);
  }

  Prayer getPrevPrayer(DateTime time) {
    PrayersModel today = PrayersModel.fromJson(_prayerList[dayInYear]);

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
    ;

    //before Isha
    PrayersModel yesterdayPrayers =
        PrayersModel.fromJson(_prayerList[dayInYear - 1]); //TODO: fix if first day of year.

    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
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

  @override
  void initState() {
    super.initState();
    NotificationsService.init();
    //  listenNotifications();
  }

  @override
  Widget build(BuildContext context) {
    dayInYear = Jiffy().dayOfYear;
    _prayerList = json.decode(prayerTimes);
    PrayersModel prayersToday = PrayersModel.fromJson(_prayerList[dayInYear]);
    var nextPrevPrayerStyle = const TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 18,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              summerTime = !summerTime;
              setSummerTime();
              setState(() {});
            },
            tooltip: 'Daylight saving',
          ),
          IconButton(
              onPressed: () {
                NotificationsService.scheduleNotifications(
                    title: 'Alfajr 1',
                    body: 'prayer has arrived 1',
                    payload: 'alfajr',
                    sheduledDate: DateTime.now().add(Duration(seconds: 5)));
              },
              icon: const Icon(Icons.notifications))
        ],
      ),
      body: FutureBuilder<bool>(
        future: getSummerTime(),
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            summerTime = snapshot.data!;
            Prayer next = getNextPrayer(DateTime.now());
            Prayer prev = getPrevPrayer(DateTime.now());

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                MyCard(
                    widget: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                            const Padding(
                                padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                                child: ClockWidget()),
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 40.0, right: 40.0),
                              visualDensity: const VisualDensity(vertical: -4),
                              leading:
                                  Text("Time until ${next.label}:   ", style: nextPrevPrayerStyle),
                              trailing: AfterClockWidget(
                                prayer: next,
                              ),
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 40.0, right: 40.0),
                              visualDensity: const VisualDensity(vertical: -4),
                              leading:
                                  Text("Time since ${prev.label}:   ", style: nextPrevPrayerStyle),
                              trailing: BeforeClockWidget(
                                prayer: prev,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
                PrayerWidget(label: "Fajr", time: toSummerTime(prayersToday.fajr)),
                PrayerWidget(label: "Shuruq", time: toSummerTime(prayersToday.shuruq)),
                PrayerWidget(label: "Duhr", time: toSummerTime(prayersToday.duhr)),
                PrayerWidget(label: "Asr", time: toSummerTime(prayersToday.asr)),
                PrayerWidget(label: "Maghrib", time: toSummerTime(prayersToday.maghrib)),
                PrayerWidget(label: "Isha", time: toSummerTime(prayersToday.isha)),
              ],
            );
          } else {
            // Return loading screen while reading preferences
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
