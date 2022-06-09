import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import '../models/prayer.dart';
import '../prayer_times.dart';
import '../models/prayers.dart';
import '../services/notifications_service.dart';
import '../services/prayer_methods.dart';
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
  late PrayersModel prayersToday;

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
    prayersToday = PrayersModel.fromJson(_prayerList[dayInYear]);

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
            Prayer next = getNextPrayer(DateTime.now(), prayersToday, summerTime, _prayerList);
            Prayer prev = getPrevPrayer(DateTime.now(), prayersToday, summerTime, _prayerList);

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
                            PrayerClockWidget(
                              prayersToday: prayersToday,
                              summerTime: summerTime,
                              prayerList: _prayerList,
                            ),
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
