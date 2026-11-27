import 'package:alfajr/resources/colors.dart';
import 'package:alfajr/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:alfajr/l10n/app_localizations.dart';

import '../data/prayer_times.dart';
import '../models/prayers.dart';
import '../services/day_of_year_service.dart';
import '../services/daylight_time_service.dart';
import '../services/locale_service.dart';
import '../services/prayer_methods.dart';
import '../services/theme_service.dart';
import 'widgets/light_swipe_page_physics.dart';
import 'widgets/prayer_widget.dart';
import 'dart:ui' as ui;

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  static const int initialPage = 50000;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final DateTime _anchorDate;
  late final PageController _pageController;
  late DateTime pickedDate;

  static DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime _dateForPage(int page) {
    final offset = page - CalendarPage.initialPage;
    return DateTime(_anchorDate.year, _anchorDate.month, _anchorDate.day + offset);
  }

  int _pageForDate(DateTime date) {
    final targetUtc = DateTime.utc(date.year, date.month, date.day);
    final anchorUtc = DateTime.utc(_anchorDate.year, _anchorDate.month, _anchorDate.day);
    final page = CalendarPage.initialPage + targetUtc.difference(anchorUtc).inDays;
    return page < 0 ? 0 : page;
  }

  void _jumpToDate(DateTime date) {
    final normalized = _normalizeDate(date);
    final targetPage = _pageForDate(normalized);
    if (_pageController.hasClients && _pageController.page?.round() != targetPage) {
      _pageController.jumpToPage(targetPage);
    }
    if (pickedDate != normalized) {
      setState(() {
        pickedDate = normalized;
      });
    }
  }

  void _goToPreviousDay() {
    if (!_pageController.hasClients) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNextDay() {
    if (!_pageController.hasClients) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  String _adjustTime(String time, bool isSummerTime, int currTimeDiff) {
    if (!isSummerTime && currTimeDiff == 0) return time;
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    var dateTime = DateTime(2000, 1, 1, hour, minute);
    dateTime = dateTime.add(Duration(hours: isSummerTime ? 1 : 0, minutes: currTimeDiff));
    return "${dateTime.hour.toString()}:${dateTime.minute.toString().padLeft(2, '0')}";
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

  @override
  void initState() {
    super.initState();
    _anchorDate = _normalizeDate(DateTime.now());
    pickedDate = _anchorDate;
    _pageController = PageController(initialPage: CalendarPage.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<DaylightSavingNotifier, ThemeNotifier, LocaleNotifier>(
      builder: (context, daylightSaving, theme, localeProvider, child) {
        final locale = localeProvider.locale.toString();
        final summerTime = daylightSaving.getSummerTimeForDate(pickedDate);
        final prayersForPickedDate = PrayersModel.fromJson(cachedPrayersList[dayOfYear(pickedDate)]);

        final dateTextWidget = Text(
          DateFormat('dd MMM yyyy', locale).format(pickedDate),
          textDirection: localeProvider.getTextDirection(localeProvider.locale),
          maxLines: 1,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 40,
              color: theme.themeMode == ThemeMode.dark ? colorTextDark : colorTextLight),
        );

        final dateTextButtonWidget = Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
            child: TextButton(
              onPressed: () async {
                final date = await pickDate();
                if (date != null && mounted) {
                  _jumpToDate(date);
                }
              },
              child: dateTextWidget,
            ));

        HijriCalendar.setLocal(locale);

        return Directionality(
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
                    onPressed: () => _jumpToDate(now),
                    tooltip: AppLocalizations.of(context)!.todayTooltip,
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    sharePrayerTimes(context, localeProvider, prayersForPickedDate, pickedDate);
                  },
                  tooltip: AppLocalizations.of(context)!.shareString,
                ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final double screenHeight = MediaQuery.of(context).size.height;
                final EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;
                final double safeBottom = MediaQuery.of(context).padding.bottom;
                final double availableHeight = (constraints.maxHeight - safeBottom).clamp(0.0, double.infinity);
                final double height3 = screenHeight - viewPadding.top - kToolbarHeight;
                final double idealTotal = height3 * 0.9;
                final double scale = idealTotal > availableHeight ? (availableHeight / idealTotal) : 1.0;
                final double prayerCardHeight = height3 * 0.1 * scale;
                final double mainCardHeight = height3 * 0.3 * scale;

                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage(theme.backgroundImage!), fit: BoxFit.cover)),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Builder(builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          final cityName = getCitiesMap(l10n)[localeProvider.city] ?? localeProvider.city;
                          final dstLabel = summerTime ? l10n.settingsSummerTime : l10n.settingsWinterTime;
                          final fasting = _diffTimes(prayersForPickedDate.fajr, prayersForPickedDate.maghrib);
                          final daylight = _diffTimes(prayersForPickedDate.shuruq, prayersForPickedDate.maghrib);

                          return MyCard(
                              height: mainCardHeight,
                              widget: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${DateFormat('EEEE', locale).format(pickedDate)}  -  ${HijriCalendar.fromDate(pickedDate).toFormat('dd MMMM yyyy')}',
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
                                            onPressed: _goToPreviousDay,
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
                                            onPressed: _goToNextDay,
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
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            pageSnapping: false,
                            physics: const LightSwipePagePhysics(),
                            onPageChanged: (page) {
                              final newDate = _dateForPage(page);
                              if (newDate != pickedDate) {
                                setState(() {
                                  pickedDate = newDate;
                                });
                              }
                            },
                            itemBuilder: (context, page) {
                              final pageDate = _dateForPage(page);
                              final pagePrayers = PrayersModel.fromJson(cachedPrayersList[dayOfYear(pageDate)]);
                              final pageSummerTime = daylightSaving.getSummerTimeForDate(pageDate);
                              final currTimeDiff = localeProvider.timeDiff;

                              return RepaintBoundary(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    PrayerWidget(
                                      label: "Fajr",
                                      time: _adjustTime(pagePrayers.fajr, pageSummerTime, currTimeDiff),
                                      height: prayerCardHeight,
                                      showAlarm: false,
                                    ),
                                    PrayerWidget(
                                      label: "Shuruq",
                                      time: _adjustTime(pagePrayers.shuruq, pageSummerTime, currTimeDiff),
                                      height: prayerCardHeight,
                                      showAlarm: false,
                                    ),
                                    PrayerWidget(
                                      label: "Duhr",
                                      time: _adjustTime(pagePrayers.duhr, pageSummerTime, currTimeDiff),
                                      height: prayerCardHeight,
                                      showAlarm: false,
                                    ),
                                    PrayerWidget(
                                      label: "Asr",
                                      time: _adjustTime(pagePrayers.asr, pageSummerTime, currTimeDiff),
                                      height: prayerCardHeight,
                                      showAlarm: false,
                                    ),
                                    PrayerWidget(
                                      label: "Maghrib",
                                      time: _adjustTime(pagePrayers.maghrib, pageSummerTime, currTimeDiff),
                                      height: prayerCardHeight,
                                      showAlarm: false,
                                    ),
                                    PrayerWidget(
                                      label: "Isha",
                                      time: _adjustTime(pagePrayers.isha, pageSummerTime, currTimeDiff),
                                      height: prayerCardHeight,
                                      showAlarm: false,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
