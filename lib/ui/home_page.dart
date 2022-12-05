import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import '../models/prayer.dart';
import '../models/prayers.dart';
import '../services/daylight_time_service.dart';
import '../services/notifications_service.dart';
import '../services/prayer_methods.dart';
import 'widgets/card_widget.dart';
import 'widgets/clock_widget.dart';
import 'widgets/daylight_saving.dart';
import 'widgets/prayer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// PrayersModel dummyDay =
//     PrayersModel("29.11", "00:11", "00:12", "00:13", "23:57", "23:58", "23:59"); //TODO: FOR TESTING

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
  PrayersModel prayersToday = PrayersModel.empty();

  Future<void> cancelAllPrayers() async {
    NotificationsService.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('scheduledPrayers', []);
    setState(() {});
  }

  Future<void> scheduleNextPrayers(DateTime time) async {
    // prayersToday = dummyDay; //TODO: FOR TESTING
    // cancelAllPrayers();

    _scheduledPrayers = await getScheduledPrayers();
    removePassedPrayers(_scheduledPrayers);
    if (_scheduledPrayers.length > 71) {
      return;
    }
    List<Prayer> prayersToSchedule = [];
    summerTime = await getSummerTime();

    prayersToSchedule.addAll(getTodayPrayers(prayersToday, summerTime));
    prayersToSchedule.addAll(getNextWeekPrayers(prayersToday, _prayerList, dayInYear, summerTime));
    for (final prayer in prayersToSchedule) {
      var id = getPrayerNotificationId(prayer.time);
      if (_scheduledPrayers.contains(id)) {
        continue;
      }

      NotificationsService.scheduleNotifications(
          id: int.parse(id.substring(6)),
          channelId: id,
          title: 'Time for ${prayer.label}',
          payload: 'alfajr',
          sheduledDate: prayer.time);

      _scheduledPrayers.add(id);
      //Set reminder
      var reminderTime = prayer.time.subtract(const Duration(minutes: 10));
      if (reminderTime.isBefore(DateTime.now())) {
        continue;
      }
      var reminderId = getPrayerNotificationId(reminderTime);
      NotificationsService.scheduleNotifications(
          id: int.parse(reminderId.substring(6)),
          channelId: reminderId,
          title: '${prayer.label} Time is in 10 minutes',
          payload: 'alfajr',
          sheduledDate: reminderTime);

      _scheduledPrayers.add(reminderId);
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

  String toSummerTime(String time) {
    if (!summerTime) return time;
    int hour = int.parse(time.split(':')[0]);
    String minute = (time.split(':')[1]);
    hour++;
    time = "$hour:$minute";
    return time;
  }

  Future<void> readJson() async {
    dayInYear = Jiffy().dayOfYear;

    final String response = await rootBundle.loadString('lib/prayer-time.json');
    final data = await json.decode(response);
    _prayerList = data["prayers"];

    setState(() {
      prayersToday = PrayersModel.fromJson(data["prayers"][dayInYear]);
    });
  }

  @override
  void initState() {
    super.initState();
    NotificationsService.init();
    readJson();
    // cancelAllPrayers(); //TODO: FOR TESTING
    //  listenNotifications();
  }

  @override
  Widget build(BuildContext context) {
    // prayersToday = dummyDay; //TODO: FOR TESTING

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.title),
        actions: const [],
      ),
      body: FutureBuilder<List>(
        future: Future.wait([
          getSummerTime(),
          scheduleNextPrayers(DateTime.now()),
          readJson(),
        ]),
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            summerTime = snapshot.data![0];
            return Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
              child: Column(
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
              ),
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
                  const Text('ALFAJR'),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
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
                height: 24,
              ),
              title: const Text('Missed Prayers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/missed_prayer');
              },
            ),
            ListTile(
              minLeadingWidth: 0,
              leading: Image.asset(
                'images/pray-white.png',
                height: 24,
              ),
              title: const Text('Al-Mathurat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/mathurat');
              },
            ),
            ListTile(
              minLeadingWidth: 0,
              leading: Image.asset(
                'images/misbaha.png',
                height: 24,
              ),
              title: const Text('Dhikr Counter'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/counter');
              },
            ),
            ListTile(
              minLeadingWidth: 0,
              leading: const Icon(Icons.access_time),
              title: const Text('Daylight saving'),
              onTap: () async {
                Navigator.pop(context);
                var updatePrayers = (() {
                  cancelAllPrayers();
                  scheduleNextPrayers(DateTime.now());
                });
                await showAlertDialog(context, updatePrayers);
              },
            ),
            ListTile(
              minLeadingWidth: 0,
              leading: Image.asset(
                'images/calendar.png',
                height: 24,
              ),
              title: const Text('Calendar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/calendar');
              },
            ),
          ],
        ),
      ),
    );
  }
}
