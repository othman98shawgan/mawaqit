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

// PrayersModel dummyDay = PrayersModel("06.09", "2:53", "10:55", "10:56", "11:48", "11:49", "11:50");

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
  List<String> _scheduledPrayers = [];
  late PrayersModel prayersToday;

  Future<void> scheduleNextPrayers(DateTime time) async {
    //TODO: for testing.
    // prayersToday = dummyDay;

    // NotificationsService.cancelAll();
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setStringList('scheduledPrayers', []);

    _scheduledPrayers = await getScheduledPrayers();
    removePassedPrayers(_scheduledPrayers);
    if (_scheduledPrayers.length > 36) {
      return;
    }
    List<Prayer> prayersToSchedule = [];
    summerTime = await getSummerTime();

    prayersToSchedule.addAll(getTodayPrayers(prayersToday, summerTime));
    prayersToSchedule.addAll(getNextWeekPrayers(prayersToday, _prayerList, dayInYear, summerTime));
    for (final prayer in prayersToSchedule) {
      if (_scheduledPrayers.contains(getPrayerNotificationId(prayer.time))) continue;
      var id = getPrayerNotificationId(prayer.time);
      NotificationsService.scheduleNotifications(
          id: int.parse(id.substring(6)),
          channelId: id,
          title: 'Time for ${prayer.label}',
          payload: 'alfajr',
          sheduledDate: prayer.time);
      _scheduledPrayers.add(getPrayerNotificationId(prayer.time));
    }
    setScheduledPrayers();
  }

  Future<List<String>> getScheduledPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    final scheduledPrayers = prefs.getStringList('scheduledPrayers') ?? [];
    return scheduledPrayers;
  }

  Future<void> setScheduledPrayers() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('scheduledPrayers', _scheduledPrayers);
  }

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
    String minute = (time.split(':')[1]);
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        ],
      ),
      body: FutureBuilder<List>(
        future: Future.wait([
          getSummerTime(),
          scheduleNextPrayers(DateTime.now()),
        ]),
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            summerTime = snapshot.data![0];
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black54,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ALFAJR'),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Image.asset(
                      'images/logo.png',
                      height: 96,
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              minLeadingWidth: 0,
              leading: Image.asset(
                'images/salah.png',
                height: 32,
              ),
              title: const Text('Missed Prayers'),
              onTap: () {},
            ),
            ListTile(
              minLeadingWidth: 0,
              leading: Image.asset(
                'images/pray-white.png',
                height: 32,
              ),
              title: const Text('Al-Mathurat'),
              onTap: () {},
            ),
            ListTile(
              minLeadingWidth: 0,
              leading: Image.asset(
                'images/misbaha.png',
                height: 32,
              ),
              title: const Text('Dhikr Counter'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
