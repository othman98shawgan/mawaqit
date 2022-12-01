import 'dart:convert';

import 'package:alfajr/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../models/prayers.dart';
import '../prayer_times.dart';
import '../services/daylight_time_service.dart';
import 'widgets/prayer_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool summerTime = false;
  List _prayerList = [];
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

  @override
  @override
  Widget build(BuildContext context) {
    dayInYear = Jiffy(pickedDate).dayOfYear;
    _prayerList = json.decode(prayerTimes);
    prayersToday = PrayersModel.fromJson(_prayerList[dayInYear]);

    var dateTextWidget = Text(
      DateFormat('dd MMM yyyy').format(pickedDate),
      style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 48, color: Colors.white),
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Calendar"),
      ),
      body: FutureBuilder<bool>(
        future: getSummerTime(),
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            summerTime = snapshot.data!;
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
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Column(
                            children: [dateTextButtonWidget],
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
    );
  }
}
