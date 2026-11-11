import 'dart:async';
import 'dart:convert';
import 'package:alfajr/resources/colors.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:alfajr/services/day_of_year_service.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/theme_service.dart';
import 'package:alfajr/ui/calendar_page.dart';
import 'package:alfajr/ui/more_page.dart';
import 'package:alfajr/ui/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:alfajr/l10n/app_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../data/prayer_times.dart';
import '../main.dart';
import '../models/prayer.dart';
import '../models/prayers.dart';
import '../services/daylight_time_service.dart';
import '../services/desktop_service.dart';
import '../services/notifications_service.dart';
import '../services/prayer_alarm_service.dart';
import 'alarm_ringing_page.dart';
import '../services/prayer_methods.dart';
import '../services/reminder_service.dart';
import '../services/store_manager.dart';
import 'widgets/card_widget.dart';
import 'widgets/clock_widget.dart';
import 'widgets/prayer_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

// PrayersModel dummyDay =
//     PrayersModel("31.12", "00:11", "00:12", "00:13", "14:45", "21:32", "22:33"); //TODO: FOR TESTING

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool summerTime = false;
  List _prayerList = [];
  int dayInYear = 0;
  List<String> _scheduledPrayers = [];
  PrayersModel prayersToday = PrayersModel.empty();
  int reminderValue = 10;
  int timeDiff = 0;
  StreamSubscription? _notificationsSub;
  StreamSubscription? _nativeAlarmSub;
  bool _isAlarmRingingOpen = false;
  Timer? _midnightTimer;
  int _currentTabIndex = 0;

  void _openAlarmRingingPage(String payload) {
    if (_isAlarmRingingOpen || !mounted) return;
    if (!payload.contains('alarm|')) return;

    final clean = payload.substring(payload.indexOf('alarm|'));
    final parts = clean.split('|');
    final prayer = parts.length >= 2 ? parts[1] : 'Fajr';
    final sound = parts.length >= 3 ? parts[2] : null;
    final snoozeMinutes = parts.length >= 4 ? int.tryParse(parts[3]) : null;
    final offsetMinutes = parts.length >= 5 ? int.tryParse(parts[4]) : null;

    _isAlarmRingingOpen = true;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AlarmRingingPage(
          prayerName: prayer,
          soundType: sound,
          snoozeMinutes: snoozeMinutes,
          offsetMinutes: offsetMinutes,
        ),
        fullscreenDialog: true,
      ),
    ).then((_) {
      _isAlarmRingingOpen = false;
    });
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.startFlexibleUpdate().then((_) {
          InAppUpdate.completeFlexibleUpdate().then((_) {
            if (mounted) printSnackBar("Success!", context);
          }).catchError((e) {
            debugPrint("InAppUpdate check error: $e");
          });
        }).catchError((e) {
          debugPrint("InAppUpdate check error: $e");
        });
      }
    }).catchError((e) {
      debugPrint("InAppUpdate check error: $e");
    });
  }

  Future<void> updateReminderValue(int val) async {
    Provider.of<ReminderNotifier>(context, listen: false).setReminderTime(val);
    setState(() {
      reminderValue = val;
    });
  }

  void updatePrayers() {
    if (!isAndroid && !isWindows && !isIOS) {
      return;
    }
    Future.delayed(Duration.zero, () {
      cancelAllPrayers().whenComplete(() => scheduleNextPrayers(DateTime.now()).whenComplete(() => setState(() {})));
    });
  }

  void updateReminder(int newReminderTime) {
    cancelAllPrayers();
    updateReminderValue(newReminderTime);
    scheduleNextPrayers(DateTime.now());
    setState(() {});
  }

  Future<void> cancelAllPrayers() async {
    NotificationsService.cancelAll();
    setScheduledPrayers([]);
  }

  Future<void> _scheduleDstTransitionNotification() async {
    final now = DateTime.now();
    final nextTransition = DaylightSavingNotifier.getNextDstTransitionEve(now);
    final eveTime = nextTransition.notificationTime;
    final toSummer = nextTransition.toSummerTime;

    const int dstNotificationId = 888000;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final title = toSummer ? l10n.dstSummerNotificationTitle : l10n.dstWinterNotificationTitle;
    final body = toSummer ? l10n.dstSummerNotificationBody : l10n.dstWinterNotificationBody;

    await NotificationsService.scheduleNotifications(
      id: dstNotificationId,
      channelId: 'dst_transition_alert',
      title: title,
      body: body,
      payload: 'dst_transition',
      sheduledDate: eveTime,
    );
  }

  Future<void> scheduleNextPrayers(DateTime time) async {
    try {
      if (!isAndroid && !isWindows && !isIOS) {
        return;
      }
    // prayersToday = dummyDay; //TODO: FOR TESTING

    final migrated = await StorageManager.readData('autoDstScheduleMigrated_v1');
    if (migrated != true) {
      await cancelAllPrayers();
      StorageManager.saveData('autoDstScheduleMigrated_v1', true);
    }

    _scheduledPrayers = await getScheduledPrayers();
    if (removePassedPrayers(_scheduledPrayers)) {
      setScheduledPrayers(_scheduledPrayers);
    }
    if (!mounted) return; //Make sure widget is mounted

    if (isAndroid) {
      final dstNotifier = Provider.of<DaylightSavingNotifier>(context, listen: false);
      final diff = Provider.of<LocaleNotifier>(context, listen: false).timeDiff;
      final titles = getLocalizedPrayerAlarmTitles(context);
      final alarmSettingsMap = await PrayerAlarmService.loadAllAlarmSettings();
      if (!mounted) return;
      final offsets = alarmSettingsMap.map((k, v) => MapEntry(k, v.offsetMinutes));
      final localizedBodies = getLocalizedPrayerAlarmMessages(context, offsets);
      await PrayerAlarmService.scheduleUpcomingAlarms(
        prayerList: _prayerList,
        summerTime: dstNotifier.getSummerTime(),
        timeDiff: diff,
        localizedTitles: titles,
        localizedBodies: localizedBodies,
      );
    }
    if (!mounted) return;

    var notifiactionsStatus = Provider.of<NotificationsStatusNotifier>(context, listen: false).getNotificationsStatus();
    var reminderStatus = Provider.of<ReminderNotifier>(context, listen: false).getReminderStatus();

    if (!notifiactionsStatus) {
      return;
    }

    await _scheduleDstTransitionNotification();
    if (!mounted) return;

    final earlyReturnLimit = reminderStatus ? (isIOS ? 45 : 71) : (isIOS ? 30 : 35);
    if (_scheduledPrayers.length > earlyReturnLimit) {
      return;
    }
    List<Prayer> prayersToSchedule = [];
    reminderValue = Provider.of<ReminderNotifier>(context, listen: false).getReminderTime();
    final dstNotifier = Provider.of<DaylightSavingNotifier>(context, listen: false);
    summerTime = dstNotifier.getSummerTime();
    timeDiff = Provider.of<LocaleNotifier>(context, listen: false).timeDiff;

    final int maxDays = (isIOS && reminderStatus) ? 4 : 6;
    prayersToSchedule.addAll(getTodayPrayers(prayersToday, summerTime, timeDiff));
    prayersToSchedule.addAll(getNextWeekPrayers(
      prayersToday,
      _prayerList,
      dayInYear,
      summerTime,
      timeDiff,
      isAutoMode: dstNotifier.isAutoDst,
      daysCount: maxDays,
    ));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final Map<String, String> prayerLabels = {
      'Fajr': getPrayerTranslation('Fajr', context),
      'Shuruq': getPrayerTranslation('Shuruq', context),
      'Duhr': getPrayerTranslation('Duhr', context),
      'Asr': getPrayerTranslation('Asr', context),
      'Maghrib': getPrayerTranslation('Maghrib', context),
      'Isha': getPrayerTranslation('Isha', context),
    };

    for (final prayer in prayersToSchedule) {
      var id = getPrayerNotificationId(prayer.time);
      if (_scheduledPrayers.contains(id)) {
        continue;
      }
      var prayerBody = '';
      var pryaerTitle = '';
      final localizedLabel = prayerLabels[prayer.label] ?? prayer.label;
      if (prayer.label == 'Shuruq') {
        prayerBody = l10n.notificationsShuruqBody;
        pryaerTitle = l10n.notificationsShuruqPrayerTimeTitle;
      } else {
        pryaerTitle = l10n.notificationsPrayerTimeTitle(localizedLabel);
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
          reminderTitle = l10n.notificationsShuruqReminderTitle(reminderValue);
          if (reminderValue <= 10) {
            reminderTitle = l10n.notificationsShuruqReminderTitleMinutes(reminderValue);
          }
        } else {
          reminderTitle = l10n.notificationsReminderTitle(localizedLabel, reminderValue);
          if (reminderValue <= 10) {
            reminderTitle = l10n.notificationsReminderTitleMinutes(localizedLabel, reminderValue);
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
    } catch (e) {
      debugPrint("Error scheduling next prayers: $e");
    }
  }

  String adjustTime(String time) {
    var currTimeDiff = Provider.of<LocaleNotifier>(context, listen: false).timeDiff;
    if (!summerTime && currTimeDiff == 0) return time;
    int hour = int.parse(time.split(':')[0]);
    int minute = int.parse(time.split(':')[1]);
    var today = DateTime.now();
    var dateTime = DateTime(today.year, today.month, today.day, hour, minute);
    dateTime = dateTime.add(Duration(hours: summerTime ? 1 : 0, minutes: currTimeDiff));
    time = "${dateTime.hour.toString()}:${dateTime.minute.toString().padLeft(2, '0')}";
    return time;
  }

  void readJson() {
    dayInYear = dayOfYear(DateTime.now());

    final data = _prayerList.isNotEmpty ? _prayerList : (json.decode(prayersJson) as List);

    setState(() {
      _prayerList = data;
      prayersToday = PrayersModel.fromJson(data[dayInYear]);
    });
  }

  void checkAndRefreshDay({bool force = false}) {
    if (!mounted) return;
    final currentDay = dayOfYear(DateTime.now());
    if (force || currentDay != dayInYear) {
      readJson();
      scheduleNextPrayers(DateTime.now());
      _setupMidnightTimer();
    } else {
      setState(() {});
    }
  }

  void _setupMidnightTimer() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now) + const Duration(seconds: 1);

    _midnightTimer = Timer(durationUntilMidnight, () {
      if (mounted) {
        checkAndRefreshDay(force: true);
      }
    });
  }

  void _onWindowRestored() {
    checkAndRefreshDay();
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
    WidgetsBinding.instance.addObserver(this);
    PrayerAlarmService.initPlatformChannel();
    PrayerAlarmService.getPendingAlarmPayload().then((payload) {
      if (payload != null && mounted) {
        _openAlarmRingingPage(payload);
      }
    });
    if (isAndroid) {
      checkForUpdate();
      WakelockPlus.enable();
    } else if (isIOS) {
      WakelockPlus.enable();
    } else if (isWindows) {
      setScheduledPrayers([]);
    }

    NotificationsService.ensureInitialized();
    readJson();
    listenNotifications();
    _setupMidnightTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        scheduleNextPrayers(DateTime.now());
      }
    });
    if (isWindows) {
      DesktopService.windowRestoredNotifier.addListener(_onWindowRestored);
    }
  }

  void listenNotifications() {
    _nativeAlarmSub?.cancel();
    _nativeAlarmSub = PrayerAlarmService.onNativeAlarmTriggered.stream.listen((payload) {
      if (payload != null && mounted) {
        _openAlarmRingingPage(payload);
      }
    });
    _notificationsSub?.cancel();
    _notificationsSub = NotificationsService.onNotifications.stream.listen((payload) {
      if (payload != null && mounted) {
        _openAlarmRingingPage(payload);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAndRefreshDay();
      PrayerAlarmService.getPendingAlarmPayload().then((payload) {
        if (payload != null && mounted) {
          _openAlarmRingingPage(payload);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (isWindows) {
      DesktopService.windowRestoredNotifier.removeListener(_onWindowRestored);
    }
    _midnightTimer?.cancel();
    _notificationsSub?.cancel();
    _nativeAlarmSub?.cancel();
    super.dispose();
  }

  Widget _buildPrayersTab(
    BuildContext context,
    ThemeNotifier theme,
    DaylightSavingNotifier daylightSaving,
    ReminderNotifier reminder,
    LocaleNotifier localeProvider,
    String title,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenHeight = MediaQuery.of(context).size.height;
          final EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;
          final double height3 = screenHeight - viewPadding.top - kToolbarHeight;
          final double idealTotal = height3 * 0.9;
          final double scale = idealTotal > constraints.maxHeight ? (constraints.maxHeight / idealTotal) : 1.0;
          final double prayerCardHeight = height3 * 0.1 * scale;
          final double mainCardHeight = height3 * 0.3 * scale;

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
                    widget: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('dd MMM yyyy', localeProvider.locale.toString())
                                      .format(DateTime.now()),
                                  strutStyle: const StrutStyle(forceStrutHeight: true),
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                                const Text(
                                  "  -  ",
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                                Text(
                                  (HijriCalendar.now().toFormat('dd MMMM yyyy')),
                                  locale: localeProvider.locale,
                                  strutStyle: const StrutStyle(forceStrutHeight: true),
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                            const Padding(
                                padding: EdgeInsets.only(top: 4.0, bottom: 4.0), child: ClockWidget()),
                            PrayerClockWidget(
                              prayersToday: prayersToday,
                              summerTime: summerTime,
                              timeDiff: timeDiff,
                              prayerList: _prayerList,
                            ),
                          ],
                        ),
                      ),
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // prayersToday = dummyDay; //TODO: FOR TESTING

    final l10n = AppLocalizations.of(context)!;
    final title = kDebugMode ? '[DEV] ${l10n.appName}' : l10n.appName;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    HijriCalendar.setLocal(Provider.of<LocaleNotifier>(context, listen: false).locale.toString());

    return Consumer5<ThemeNotifier, DaylightSavingNotifier, ReminderNotifier, LocaleNotifier,
        NotificationsStatusNotifier>(
      builder: (context, theme, daylightSaving, reminder, localeProvider, notifications, child) {
        final isDark = theme.themeMode == ThemeMode.dark;
        final textDirection = localeProvider.getTextDirection(localeProvider.locale);

        return PopScope(
          canPop: _currentTabIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _currentTabIndex != 0) {
              setState(() {
                _currentTabIndex = 0;
              });
            }
          },
          child: Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Scaffold(
              body: IndexedStack(
                index: _currentTabIndex,
                children: [
                  _buildPrayersTab(context, theme, daylightSaving, reminder, localeProvider, title),
                  const CalendarPage(),
                  const SizedBox.shrink(),
                  SettingsPage(
                    updatePrayers: updatePrayers,
                    updateReminder: updateReminder,
                    cancelNotifications: cancelAllPrayers,
                  ),
                  const SizedBox.shrink(),
                ],
              ),
              bottomNavigationBar: Directionality(
                textDirection: textDirection,
                child: BottomNavigationBar(
                  currentIndex: _currentTabIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: isDark ? appBarColor : color5,
                  selectedItemColor: isDark ? Colors.tealAccent : Colors.white,
                  unselectedItemColor: isDark ? Colors.white60 : Colors.white60,
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  onTap: (index) async {
                    if (index == 2) {
                      await _launchURL('https://qiblafinder.withgoogle.com/');
                      return;
                    }
                    if (index == 4) {
                      await showMoreBottomSheet(context, prayersToday);
                      return;
                    }
                    setState(() {
                      _currentTabIndex = index;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.access_time),
                      activeIcon: const Icon(Icons.access_time_filled),
                      label: l10n.prayersTabString,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.calendar_month_outlined),
                      activeIcon: const Icon(Icons.calendar_month),
                      label: l10n.calendarTabString,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.mosque_outlined),
                      activeIcon: const Icon(Icons.mosque),
                      label: l10n.qiblaString,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.settings_outlined),
                      activeIcon: const Icon(Icons.settings),
                      label: l10n.settingsString,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.more_horiz),
                      activeIcon: const Icon(Icons.more_horiz),
                      label: l10n.moreString,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String urlAddress) async {
    Uri url = Uri.parse(urlAddress);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
