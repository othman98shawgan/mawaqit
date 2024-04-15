import 'dart:async';
import 'dart:convert';
import 'package:alfajr/resources/colors.dart';
import 'package:alfajr/services/day_of_year_service.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/theme_service.dart';
import 'package:alfajr/ui/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wakelock/wakelock.dart';
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
import 'dart:ui' as ui;

// PrayersModel dummyDay =
//     PrayersModel("31.12", "00:11", "00:12", "00:13", "14:45", "21:32", "22:33"); //TODO: FOR TESTING

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
  List<IconButton> appBarActions = [];
  int timeDiff = 0;

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.startFlexibleUpdate().then((_) {
          InAppUpdate.completeFlexibleUpdate().then((_) {
            printSnackBar("Success!", context);
          }).catchError((e) {
            printSnackBar(e.toString(), context);
          });
        }).catchError((e) {
          printSnackBar(e.toString(), context);
        });
      }
    }).catchError((e) {
      printSnackBar(e.toString(), context);
    });
  }

  Future<void> updateReminderValue(int val) async {
    Provider.of<ReminderNotifier>(context, listen: false).setReminderTime(val);
    setState(() {
      reminderValue = val;
    });
  }

  updatePrayers() {
    Future.delayed(Duration.zero, () {
      cancelAllPrayers().whenComplete(() => scheduleNextPrayers(DateTime.now()).whenComplete(() => setState(() {})));
    });
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

    _scheduledPrayers = await getScheduledPrayers();
    if (removePassedPrayers(_scheduledPrayers)) {
      setScheduledPrayers(_scheduledPrayers);
    }
    if (!mounted) return; //Make sure widget is mounted
    var notifiactionsStatus = Provider.of<NotificationsStatusNotifier>(context, listen: false).getNotificationsStatus();
    var reminderStatus = Provider.of<ReminderNotifier>(context, listen: false).getReminderStatus();

    if ((!notifiactionsStatus) ||
        (reminderStatus && _scheduledPrayers.length > 71) ||
        (!reminderStatus && _scheduledPrayers.length > 35)) {
      return;
    }
    List<Prayer> prayersToSchedule = [];
    reminderValue = Provider.of<ReminderNotifier>(context, listen: false).getReminderTime();
    summerTime = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime();
    timeDiff = Provider.of<LocaleNotifier>(context, listen: false).timeDiff;

    prayersToSchedule.addAll(getTodayPrayers(prayersToday, summerTime, timeDiff));
    prayersToSchedule.addAll(getNextWeekPrayers(prayersToday, _prayerList, dayInYear, summerTime, timeDiff));
    for (final prayer in prayersToSchedule) {
      var id = getPrayerNotificationId(prayer.time);
      if (_scheduledPrayers.contains(id)) {
        continue;
      }
      var prayerBody = '';
      var pryaerTitle = '';
      if (prayer.label == 'Shuruq') {
        prayerBody = AppLocalizations.of(context)!.notificationsShuruqBody;
        pryaerTitle = AppLocalizations.of(context)!.notificationsShuruqPrayerTimeTitle;
      } else {
        pryaerTitle =
            AppLocalizations.of(context)!.notificationsPrayerTimeTitle(getPrayerTranslation(prayer.label, context));
      }

      NotificationsService.scheduleNotifications(
          id: int.parse(id.substring(6)),
          channelId: id,
          title: pryaerTitle,
          body: prayerBody,
          payload: 'alfajr',
          sheduledDate: prayer.time);

      _scheduledPrayers.add(id);
      //Set reminder
      if (reminderStatus) {
        var reminderTime = prayer.time.subtract(Duration(minutes: reminderValue));
        if (reminderTime.isBefore(DateTime.now())) {
          continue;
        }
        var reminderId = getPrayerNotificationId(reminderTime);
        var reminderTitle = '';
        if (prayer.label == 'Shuruq') {
          reminderTitle = AppLocalizations.of(context)!.notificationsShuruqReminderTitle(reminderValue);
          if (reminderValue <= 10) {
            reminderTitle = AppLocalizations.of(context)!.notificationsShuruqReminderTitleMinutes(reminderValue);
          }
        } else {
          reminderTitle = AppLocalizations.of(context)!
              .notificationsReminderTitle(getPrayerTranslation(prayer.label, context), reminderValue);
          if (reminderValue <= 10) {
            reminderTitle = AppLocalizations.of(context)!
                .notificationsReminderTitleMinutes(getPrayerTranslation(prayer.label, context), reminderValue);
          }
        }

        NotificationsService.scheduleNotifications(
          id: int.parse(reminderId.substring(6)),
          channelId: reminderId,
          title: reminderTitle,
          payload: 'alfajr',
          sheduledDate: reminderTime,
        );

        _scheduledPrayers.add(reminderId);
      }
    }

    setScheduledPrayers(_scheduledPrayers);
  }

  String adjustTime(String time) {
    var currTimeDiff = Provider.of<LocaleNotifier>(context, listen: false).timeDiff;
    if (!summerTime && currTimeDiff == 0) return time;
    int hour = int.parse(time.split(':')[0]);
    int minute = int.parse(time.split(':')[1]);
    var today = DateTime.now();
    var dateTime = DateTime(today.year, today.month, today.day, hour, minute);
    dateTime = dateTime.add(Duration(hours: 1, minutes: currTimeDiff));
    time = "${dateTime.hour.toString()}:${dateTime.minute.toString().padLeft(2, '0')}";
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
  void didChangeDependencies() {
    // Adjust the provider based on the image type
    precacheImage(const AssetImage('images/bg.png'), context);
    precacheImage(const AssetImage('images/bgGreen.png'), context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    checkForUpdate();
    Wakelock.enable();
    updateAppBar(false);
    NotificationsService.init();
    readJson();
    // cancelAllPrayers(); //TODO: FOR TESTING
    // scheduleNextPrayers(DateTime.now()); //TODO: FOR TESTING
    //  listenNotifications();
  }

  void updateAppBar(bool added) {
    appBarActions = [
      IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Settings',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(
                updatePrayers: updatePrayers,
                updateReminder: updateReminder,
                cancelNotifications: cancelAllPrayers,
                updateAppBar: updateAppBar,
              ),
            ),
          );
        },
      ),
    ];
    if (!added) {
      return;
    }
    List<IconButton> newAppBarActions = [
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () {
          Navigator.pushNamed(context, '/notifications');
        },
        tooltip: 'Notifications',
      ),
      IconButton(
        icon: const Icon(Icons.cancel),
        onPressed: () {
          cancelAllPrayers();
        },
        tooltip: 'Cancel Prayers',
      ),
    ];
    appBarActions.addAll(newAppBarActions);
    appBarActions = appBarActions.reversed.toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // prayersToday = dummyDay; //TODO: FOR TESTING

    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).viewPadding;
    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;
    double prayerCardHeight = height3 * 0.1;
    double mainCardHeight = height3 * 0.3;
    var title = AppLocalizations.of(context)!.appName;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    HijriCalendar.setLocal(Provider.of<LocaleNotifier>(context, listen: false).locale.toString());
    var themeMode = Provider.of<ThemeNotifier>(context, listen: false).themeMode;
    var iconColor = themeMode == ThemeMode.dark ? colorTextDark : colorTextLight;

    return Consumer5<ThemeNotifier, DaylightSavingNotifier, ReminderNotifier, LocaleNotifier,
        NotificationsStatusNotifier>(
      builder: (context, theme, daylightSaving, reminder, localeProvider, notifications, child) => Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            actions: appBarActions,
          ),
          body: FutureBuilder<List>(
            future: Future.wait([
              scheduleNextPrayers(DateTime.now()),
            ]),
            builder: (buildContext, snapshot) {
              if (snapshot.hasData) {
                summerTime = daylightSaving.getSummerTime();
                reminderValue = reminder.getReminderTime();
                timeDiff = localeProvider.timeDiff;
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage(theme.backgroundImage!), fit: BoxFit.cover)),
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
                                        Text(
                                          DateFormat('dd MMM yyyy', localeProvider.locale.toString())
                                              .format(DateTime.now()),
                                          strutStyle: const StrutStyle(forceStrutHeight: true),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Text(
                                          "  -  ",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          (HijriCalendar.now().toFormat('dd MMMM yyyy')),
                                          locale: localeProvider.locale,
                                          strutStyle: const StrutStyle(forceStrutHeight: true),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0), child: ClockWidget()),
                                    PrayerClockWidget(
                                      prayersToday: prayersToday,
                                      summerTime: summerTime,
                                      timeDiff: timeDiff,
                                      prayerList: _prayerList,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      PrayerWidget(
                        label: "Fajr",
                        time: adjustTime(prayersToday.fajr),
                        height: prayerCardHeight,
                      ),
                      PrayerWidget(
                        label: "Shuruq",
                        time: adjustTime(prayersToday.shuruq),
                        height: prayerCardHeight,
                      ),
                      PrayerWidget(
                        label: "Duhr",
                        time: adjustTime(prayersToday.duhr),
                        height: prayerCardHeight,
                      ),
                      PrayerWidget(
                        label: "Asr",
                        time: adjustTime(prayersToday.asr),
                        height: prayerCardHeight,
                      ),
                      PrayerWidget(
                        label: "Maghrib",
                        time: adjustTime(prayersToday.maghrib),
                        height: prayerCardHeight,
                      ),
                      PrayerWidget(
                        label: "Isha",
                        time: adjustTime(prayersToday.isha),
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
                      Text(AppLocalizations.of(context)!.appName),
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
                  leading: Icon(Icons.calendar_month, color: iconColor),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppLocalizations.of(context)!.calendarString,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/calendar');
                  },
                ),
                ListTile(
                  minLeadingWidth: 0,
                  leading: Image.asset(
                    'images/misbaha.png',
                    height: 24,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppLocalizations.of(context)!.dhikrString,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/counter');
                  },
                ),
                ListTile(
                  minLeadingWidth: 0,
                  leading: Image.asset(
                    'images/salah.png',
                    height: 24,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppLocalizations.of(context)!.missedPrayersString,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/missed_prayer');
                  },
                ),
                ListTile(
                  minLeadingWidth: 0,
                  leading: Icon(Icons.mosque, color: iconColor),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppLocalizations.of(context)!.qiblaString,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _launchURL('https://qiblafinder.withgoogle.com/');
                  },
                ),
                const Divider(thickness: 1),
                ListTile(
                  minLeadingWidth: 0,
                  leading: Icon(Icons.apps, color: iconColor),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppLocalizations.of(context)!.ourAppsString,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/apps');
                  },
                ),
                ListTile(
                  minLeadingWidth: 0,
                  leading: Icon(Icons.email, color: iconColor),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppLocalizations.of(context)!.contactUsString,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _contactUs();
                  },
                ),
                ListTile(
                  minLeadingWidth: 0,
                  leading: Icon(Icons.share, color: iconColor),
                  title: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppLocalizations.of(context)!.shareString,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await sharePrayerTimes(context, localeProvider, prayersToday, DateTime.now());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _launchURL(String urlAddress) async {
    Uri url = Uri.parse(urlAddress);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  _contactUs() async {
    String mailAddress = 'mailto:oth1998@gmail.com';
    String urlAddress = '$mailAddress?subject=تطبيق مواقيت بيت المقدس&body=السلام عليكم ورحمة الله، \n';
    Uri url = Uri.parse(urlAddress);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
