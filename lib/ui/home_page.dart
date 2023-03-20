import 'dart:async';
import 'dart:convert';
import 'package:alfajr/services/day_of_year_service.dart';
import 'package:alfajr/ui/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/prayer_times.dart';
import '../models/prayer.dart';
import '../models/prayers.dart';
import '../services/daylight_time_service.dart';
import '../services/notifications_service.dart';
import '../services/prayer_methods.dart';
import '../services/reminder_service.dart';
import 'widgets/card_widget.dart';
import 'widgets/clock_widget.dart';
import 'widgets/prayer_widget.dart';
import 'package:url_launcher/url_launcher.dart';

// PrayersModel dummyDay =
//     PrayersModel("31.12", "00:11", "00:12", "00:13", "14:45", "21:32", "22:33"); //TODO: FOR TESTING

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
  int reminderValue = 10;

  Future<void> updateReminderValue(int val) async {
    Provider.of<ReminderNotifier>(context, listen: false).setReminderTime(val);
    setState(() {
      reminderValue = val;
    });
  }

  updatePrayers() {
    cancelAllPrayers().whenComplete(
        () => scheduleNextPrayers(DateTime.now()).whenComplete(() => setState(() {})));
  }

  updateReminder(int newReminderTime) {
    cancelAllPrayers();
    updateReminderValue(newReminderTime);
    scheduleNextPrayers(DateTime.now());
    setState(() {});
  }

  Future<void> cancelAllPrayers() async {
    NotificationsService.cancelAll();
    setScheduledPrayers([]);
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
    if (!mounted) return; //Make sure widget is mounted
    reminderValue = Provider.of<ReminderNotifier>(context, listen: false).getReminderTime();
    summerTime = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime();

    prayersToSchedule.addAll(getTodayPrayers(prayersToday, summerTime));
    prayersToSchedule.addAll(getNextWeekPrayers(prayersToday, _prayerList, dayInYear, summerTime));
    for (final prayer in prayersToSchedule) {
      var id = getPrayerNotificationId(prayer.time);
      if (_scheduledPrayers.contains(id)) {
        continue;
      }
      var prayerBody = '';
      if (prayer.label == 'Shuruq') {
        prayerBody = 'You can pray Duha in around 20 minutes';
      }
      NotificationsService.scheduleNotifications(
          id: int.parse(id.substring(6)),
          channelId: id,
          title: 'Time for ${prayer.label}',
          body: prayerBody,
          payload: 'alfajr',
          sheduledDate: prayer.time);

      _scheduledPrayers.add(id);
      //Set reminder
      var reminderTime = prayer.time.subtract(Duration(minutes: reminderValue));
      if (reminderTime.isBefore(DateTime.now())) {
        continue;
      }
      var reminderId = getPrayerNotificationId(reminderTime);
      var reminderTitle = '';
      if (prayer.label == 'Shuruq') {
        reminderTitle = '${prayer.label} is in $reminderValue minutes';
      } else {
        reminderTitle = '${prayer.label} Azan is in $reminderValue minutes';
      }

      NotificationsService.scheduleNotifications(
          id: int.parse(reminderId.substring(6)),
          channelId: reminderId,
          title: reminderTitle,
          payload: 'alfajr',
          sheduledDate: reminderTime);

      _scheduledPrayers.add(reminderId);
    }

    setScheduledPrayers(_scheduledPrayers);
  }

  String toSummerTime(String time) {
    if (!summerTime) return time;
    int hour = int.parse(time.split(':')[0]);
    String minute = (time.split(':')[1]);
    hour++;
    time = "$hour:$minute";
    return time;
  }

  void readJson() {
    dayInYear = dayOfYear(DateTime.now());

    // final String response = await rootBundle.loadString('lib/data/prayer-time.json');
    final data = json.decode(prayersJson);

    setState(() {
      _prayerList = data;
      prayersToday = PrayersModel.fromJson(data[dayInYear]);
    });
  }

  @override
  void initState() {
    super.initState();
    NotificationsService.init();
    readJson();
    scheduleNextPrayers(DateTime.now());
    // cancelAllPrayers(); //TODO: FOR TESTING
    // scheduleNextPrayers(DateTime.now()); //TODO: FOR TESTING
    //  listenNotifications();
  }

  @override
  Widget build(BuildContext context) {
    // prayersToday = dummyDay; //TODO: FOR TESTING

    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).viewPadding;
    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;
    double prayerCardHeight = height3 * 0.11;
    double mainCardHeight = height3 * 0.28;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Consumer2<DaylightSavingNotifier, ReminderNotifier>(
      builder: (context, daylightSaving, reminder, child) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.cancel),
            //   onPressed: () {
            //     cancelAllPrayers();
            //   },
            //   tooltip: 'Cancel Prayers',
            // ),
            // IconButton(
            //   icon: const Icon(Icons.notifications),
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/notifications');
            //   },
            //   tooltip: 'Notifications',
            // ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      title: 'Settings Page',
                      updateSummerTime: updatePrayers,
                      updateReminder: updateReminder,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<List>(
          future: Future.wait([
            // readJson(),
          ]),
          builder: (buildContext, snapshot) {
            if (snapshot.hasData) {
              summerTime = daylightSaving.getSummerTime();
              reminderValue = reminder.getReminderTime();
              return Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
                child: Column(
                  children: <Widget>[
                    MyCard(
                        height: mainCardHeight,
                        widget: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                                      const Text("  -  "),
                                      Text((HijriCalendar.now().toFormat('dd MMMM yyyy'))),
                                    ],
                                  ),                                  
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
                          ],
                        )),
                    PrayerWidget(
                      label: "Fajr",
                      time: toSummerTime(prayersToday.fajr),
                      height: prayerCardHeight,
                    ),
                    PrayerWidget(
                      label: "Shuruq",
                      time: toSummerTime(prayersToday.shuruq),
                      height: prayerCardHeight,
                    ),
                    PrayerWidget(
                      label: "Duhr",
                      time: toSummerTime(prayersToday.duhr),
                      height: prayerCardHeight,
                    ),
                    PrayerWidget(
                      label: "Asr",
                      time: toSummerTime(prayersToday.asr),
                      height: prayerCardHeight,
                    ),
                    PrayerWidget(
                      label: "Maghrib",
                      time: toSummerTime(prayersToday.maghrib),
                      height: prayerCardHeight,
                    ),
                    PrayerWidget(
                      label: "Isha",
                      time: toSummerTime(prayersToday.isha),
                      height: prayerCardHeight,
                    ),
                  ],
                ),
              );
            } else {
              // Return loading screen while reading preferences
              return const SizedBox.shrink();
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
                    const Text('Mawaqit Al-Quds'),
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
              ListTile(
                minLeadingWidth: 0,
                leading: const Icon(Icons.mosque),
                title: const Text('Qibla'),
                onTap: () async {
                  Navigator.pop(context);
                  await _launchURL();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _launchURL() async {
    Uri url = Uri.parse('https://qiblafinder.withgoogle.com/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
