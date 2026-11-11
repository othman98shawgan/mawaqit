import 'dart:convert';

import 'package:alfajr/resources/colors.dart';
import 'package:alfajr/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:alfajr/l10n/app_localizations.dart';

import '../models/prayers.dart';
import '../services/day_of_year_service.dart';
import '../services/daylight_time_service.dart';
import '../services/locale_service.dart';
import '../services/prayer_methods.dart';
import '../services/theme_service.dart';
import 'widgets/prayer_widget.dart';
import 'dart:ui' as ui;

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool summerTime = false;
  int dayInYear = 0;
  late PrayersModel prayersToday;
  var pickedDate = DateTime.now();

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

  Duration _diffTimes(String startTime, String endTime) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final start = DateTime(2000, 1, 1, int.parse(startParts[0]), int.parse(startParts[1]));
    final end = DateTime(2000, 1, 1, int.parse(endParts[0]), int.parse(endParts[1]));
    return end.difference(start);
  }

  Widget _buildTodayIcon(int day) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            width: double.infinity,
            color: Colors.white,
          ),
          Expanded(
            child: Center(
              child: Text(
                '$day',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: DateTime(pickedDate.year - 50),
        lastDate: DateTime(pickedDate.year + 50),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDatePickerMode: DatePickerMode.day,
      );

  Future<void> readJson() async {
    dayInYear = dayOfYear(pickedDate);

    final String response = await rootBundle.loadString('lib/data/prayer-time.json');
    final data = await json.decode(response);

    setState(() {
      prayersToday = PrayersModel.fromJson(data["prayers"][dayInYear]);
    });
  }

  @override
  void initState() {
    super.initState();
    summerTime = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime();
  }

  @override
  Widget build(BuildContext context) {
    var themeMode = Provider.of<ThemeNotifier>(context, listen: false).themeMode;
    var localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    var locale = localeNotifier.locale.toString();

    var dateTextWidget = Text(
      DateFormat('dd MMM yyyy', locale).format(pickedDate),
      textDirection: localeNotifier.getTextDirection(localeNotifier.locale),
      maxLines: 1,
      style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 40,
          color: themeMode == ThemeMode.dark ? colorTextDark : colorTextLight),
    );

    var dateTextButtonWidget = Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: TextButton(
          onPressed: () async {
            final date = await pickDate();
            if (date != null && date != pickedDate) {
              setState(() {
                pickedDate = date;
                summerTime =
                    Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTimeForDate(pickedDate);
              });
            }
          },
          child: dateTextWidget,
        ));

    HijriCalendar.setLocal(locale);

    return Consumer3<DaylightSavingNotifier, ThemeNotifier, LocaleNotifier>(
      builder: (context, daylightSaving, theme, localeProvider, child) => Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                AppLocalizations.of(context)!.calendarString,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            actions: [
              Builder(builder: (context) {
                final now = DateTime.now();
                final isToday =
                    pickedDate.year == now.year && pickedDate.month == now.month && pickedDate.day == now.day;
                if (isToday) return const SizedBox.shrink();
                return IconButton(
                  icon: _buildTodayIcon(now.day),
                  onPressed: () {
                    setState(() {
                      pickedDate = now;
                      summerTime = daylightSaving.getSummerTimeForDate(pickedDate);
                    });
                  },
                  tooltip: AppLocalizations.of(context)!.todayTooltip,
                );
              }),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  sharePrayerTimes(context, localeProvider, prayersToday, pickedDate);
                },
                tooltip: AppLocalizations.of(context)!.shareString,
              ),
            ],
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

              return FutureBuilder<List>(
                future: Future.wait([
                  readJson(),
                ]),
                builder: (buildContext, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(image: AssetImage(theme.backgroundImage!), fit: BoxFit.cover)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Builder(builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            final cityName = getCitiesMap(l10n)[localeProvider.city] ?? localeProvider.city;
                            final dstLabel = summerTime ? l10n.settingsSummerTime : l10n.settingsWinterTime;
                            final fasting = _diffTimes(prayersToday.fajr, prayersToday.maghrib);
                            final daylight = _diffTimes(prayersToday.shuruq, prayersToday.maghrib);

                            return MyCard(
                                height: mainCardHeight,
                                widget: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${DateFormat('EEEE', localeProvider.locale.toString()).format(pickedDate)}  -  ${HijriCalendar.fromDate(pickedDate).toFormat('dd MMMM yyyy')}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 2),
                                      Directionality(
                                        textDirection: ui.TextDirection.ltr,
                                        child: Row(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              iconSize: 44,
                                              icon: const Icon(Icons.navigate_before),
                                              onPressed: () {
                                                setState(() {
                                                  pickedDate = pickedDate.subtract(const Duration(days: 1));
                                                  summerTime = daylightSaving.getSummerTimeForDate(pickedDate);
                                                });
                                              },
                                              tooltip: l10n.prevoiusDayTooltip,
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: dateTextButtonWidget,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              iconSize: 44,
                                              icon: const Icon(Icons.navigate_next),
                                              onPressed: () {
                                                setState(() {
                                                  pickedDate = pickedDate.add(const Duration(days: 1));
                                                  summerTime = daylightSaving.getSummerTimeForDate(pickedDate);
                                                });
                                              },
                                              tooltip: l10n.nextDayTooltip,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$cityName  •  $dstLabel',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 15, color: Colors.white70),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${l10n.fastingDuration(fasting.inHours, fasting.inMinutes.remainder(60))}  •  ${l10n.daylightDuration(daylight.inHours, daylight.inMinutes.remainder(60))}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ));
                          }),
                          PrayerWidget(
                            label: "Fajr",
                            time: adjustTime(prayersToday.fajr),
                            height: prayerCardHeight,
                            showAlarm: false,
                          ),
                          PrayerWidget(
                            label: "Shuruq",
                            time: adjustTime(prayersToday.shuruq),
                            height: prayerCardHeight,
                            showAlarm: false,
                          ),
                          PrayerWidget(
                            label: "Duhr",
                            time: adjustTime(prayersToday.duhr),
                            height: prayerCardHeight,
                            showAlarm: false,
                          ),
                          PrayerWidget(
                            label: "Asr",
                            time: adjustTime(prayersToday.asr),
                            height: prayerCardHeight,
                            showAlarm: false,
                          ),
                          PrayerWidget(
                            label: "Maghrib",
                            time: adjustTime(prayersToday.maghrib),
                            height: prayerCardHeight,
                            showAlarm: false,
                          ),
                          PrayerWidget(
                            label: "Isha",
                            time: adjustTime(prayersToday.isha),
                            height: prayerCardHeight,
                            showAlarm: false,
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Return loading screen while reading preferences
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
