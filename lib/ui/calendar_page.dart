import 'dart:convert';

import 'package:alfajr/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/prayers.dart';
import '../services/day_of_year_service.dart';
import '../services/daylight_time_service.dart';
import 'widgets/prayer_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool summerTime = false;
  int dayInYear = 0;
  late PrayersModel prayersToday;
  var pickedDate = DateTime.now();

  String toSummerTime(String time) {
    if (!summerTime) return time;
    int hour = int.parse(time.split(':')[0]);
    String minute = (time.split(':')[1]);
    hour++;
    time = "$hour:$minute";
    return time;
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
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).viewPadding;
    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;
    double prayerCardHeight = height3 * 0.11;
    double mainCardHeight = height3 * 0.20;
    var sunIcon = const Icon(Icons.light_mode);
    var moonIcon = const Icon(Icons.dark_mode);

    var dateTextWidget = Text(
      DateFormat('dd MMM yyyy').format(pickedDate),
      style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 40, color: Colors.white),
    );

    var dateTextButtonWidget = Padding(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: TextButton(
          onPressed: () async {
            final date = await pickDate();
            if (date != null && date != pickedDate) {
              setState(() {
                pickedDate = date;
              });
            }
          },
          child: dateTextWidget,
        ));

    return Consumer<DaylightSavingNotifier>(
      builder: (context, daylightSaving, child) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Calendar"),
          actions: [
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () {
                setState(() {
                  pickedDate = DateTime.now();
                });
              },
              tooltip: 'Today',
            ),
            IconButton(
              icon: summerTime ? sunIcon : moonIcon,
              onPressed: () {
                setState(() {
                  summerTime = !summerTime;
                });
              },
              tooltip: 'Daylight Saving Mode',
            ),
          ],
        ),
        body: FutureBuilder<List>(
          future: Future.wait([
            readJson(),
          ]),
          builder: (buildContext, snapshot) {
            if (snapshot.hasData) {
              return Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    MyCard(
                        height: mainCardHeight,
                        widget: Column(
                          children: [
                            Text(DateFormat('EEEE').format(pickedDate)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 36,
                                  icon: const Icon(Icons.navigate_before),
                                  onPressed: () {
                                    setState(() {
                                      pickedDate = pickedDate.subtract(const Duration(days: 1));
                                    });
                                  },
                                  tooltip: 'Prevoius Day',
                                ),
                                dateTextButtonWidget,
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 36,
                                  icon: const Icon(Icons.navigate_next),
                                  onPressed: () {
                                    setState(() {
                                      pickedDate = pickedDate.add(const Duration(days: 1));
                                    });
                                  },
                                  tooltip: 'Next Day',
                                ),
                              ],
                            )
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
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
