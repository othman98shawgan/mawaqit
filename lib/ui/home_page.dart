import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jiffy/jiffy.dart';
import '../prayer_times.dart';
import '../prayers.dart';
import 'widgets/card_widget.dart';
import 'widgets/prayer_widget.dart';

class Prayer {
  final String label;
  final String time;

  Prayer(this.label, this.time);
}

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

  String toSummerTime(String time) {
    if (!summerTime) return time;
    int hour = int.parse(time.split(':')[0]);
    int minute = int.parse(time.split(':')[1]);
    hour++;
    time = "$hour:$minute";
    return time;
  }

  DateTime getNextPrayer(DateTime time) {
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
      fajr.add(const Duration(hours: 1));
      shuruq.add(const Duration(hours: 1));
      duhr.add(const Duration(hours: 1));
      asr.add(const Duration(hours: 1));
      maghrib.add(const Duration(hours: 1));
      isha.add(const Duration(hours: 1));
    }

    if (time.isBefore(fajr)) return fajr;
    if (time.isBefore(shuruq)) return shuruq;
    if (time.isBefore(duhr)) return duhr;
    if (time.isBefore(asr)) return asr;
    if (time.isBefore(maghrib)) return maghrib;
    if (time.isBefore(isha)) return isha;

    //after Isha
    PrayersModel tomorrowPrayers =
        PrayersModel.fromJson(_prayerList[dayInYear + 1]); //TODO: fix if last day of year.
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, getHour(tomorrowPrayers.fajr),
        getMinute(tomorrowPrayers.fajr));
  }

  DateTime getPrevPrayer(DateTime time) {
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
      fajr.add(const Duration(hours: 1));
      shuruq.add(const Duration(hours: 1));
      duhr.add(const Duration(hours: 1));
      asr.add(const Duration(hours: 1));
      maghrib.add(const Duration(hours: 1));
      isha.add(const Duration(hours: 1));
    }

    if (time.isAfter(isha)) return isha;
    if (time.isAfter(maghrib)) return maghrib;
    if (time.isAfter(asr)) return asr;
    if (time.isAfter(duhr)) return duhr;
    if (time.isAfter(shuruq)) return shuruq;
    if (time.isAfter(fajr)) return fajr;

    //before Isha
    PrayersModel yesterdayPrayers =
        PrayersModel.fromJson(_prayerList[dayInYear - 1]); //TODO: fix if first day of year.

    DateTime yesterday = DateTime.now().add(const Duration(days: -1));
    DateTime ishaYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day,
        getHour(yesterdayPrayers.isha), getMinute(yesterdayPrayers.isha));
    return summerTime ? ishaYesterday.add(const Duration(hours: 1)) : ishaYesterday;
  }

  int getHour(String time) {
    return int.parse(time.split(':')[0]);
  }

  int getMinute(String time) {
    return int.parse(time.split(':')[1]);
  }

  @override
  Widget build(BuildContext context) {
    dayInYear = Jiffy().dayOfYear;
    _prayerList = json.decode(prayerTimes);
    PrayersModel prayersToday = PrayersModel.fromJson(_prayerList[dayInYear]);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              summerTime = !summerTime;
              setState(() {});
            },
            tooltip: 'Daylight saving',
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MyCard(
            widget: ListTile(
              title: Center(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                        ClockWidget(),
                        AfterClockWidget(
                          time: getNextPrayer(DateTime.now()),
                        ),
                        BeforeClockWidget(
                          time: getPrevPrayer(DateTime.now()),
                        )
                      ],
                    )),
              ),
            ),
          ),
          PrayerWidget(label: "Fajr", time: toSummerTime(prayersToday.fajr)),
          PrayerWidget(label: "Shuruq", time: toSummerTime(prayersToday.shuruq)),
          PrayerWidget(label: "Duhr", time: toSummerTime(prayersToday.duhr)),
          PrayerWidget(label: "Asr", time: toSummerTime(prayersToday.asr)),
          PrayerWidget(label: "Maghrib", time: toSummerTime(prayersToday.maghrib)),
          PrayerWidget(label: "Isha", time: toSummerTime(prayersToday.isha)),
        ],
      ),
    );
  }
}

class ClockWidget extends StatelessWidget {
  const ClockWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      return Text(
        DateFormat('kk:mm:ss').format(DateTime.now()),
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 48,
        ),
      );
    });
  }
}

class BeforeClockWidget extends StatelessWidget {
  const BeforeClockWidget({Key? key, required this.time}) : super(key: key);
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      return Text(
        DateFormat('kk:mm:ss')
            .format(DateTime.now().subtract(Duration(hours: time.hour, minutes: time.minute))),
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 32,
        ),
      );
    });
  }
}

class AfterClockWidget extends StatelessWidget {
  const AfterClockWidget({Key? key, required this.time}) : super(key: key);
  final DateTime time;

  String printDuration(Duration duration) {
    return "${addZero(duration.inHours.toString())}:"
        "${addZero(duration.inMinutes.remainder(60).toString())}:"
        "${addZero(duration.inSeconds.remainder(60).toString())}";
  }

  String addZero(String time) {
    if (time.length == 2) return time;
    return '0$time';
  }

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      return Text(
        printDuration(time.difference(DateTime.now())),
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 32,
        ),
      );
    });
  }
}
