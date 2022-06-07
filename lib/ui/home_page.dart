import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jiffy/jiffy.dart';
import '../prayer_times.dart';
import '../prayer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool summerTime = false;
  List _prayerList = [];

  String toSummerTime(String time) {
    if (!summerTime) return time;
    int hour = int.parse(time.split(':')[0]);
    int minute = int.parse(time.split(':')[1]);
    hour++;
    time = "$hour:$minute";
    return time;
  }

  @override
  Widget build(BuildContext context) {
    var dayInYear = Jiffy().dayOfYear;
    PrayerModel prayersToday =
        PrayerModel.fromJson(json.decode(prayerTimes)[dayInYear]);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              summerTime = !summerTime;
              setState(() {});
            },
            tooltip: 'Daylight saving',
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MyCard(
            widget: ListTile(
              title: Center(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                        const ClockWidget()
                      ],
                    )),
              ),
            ),
          ),
          PrayerWidget(label: "Fajr", time: toSummerTime(prayersToday.fajr)),
          PrayerWidget(
              label: "Shuruq", time: toSummerTime(prayersToday.shuruq)),
          PrayerWidget(label: "Duhr", time: toSummerTime(prayersToday.duhr)),
          PrayerWidget(label: "Asr", time: toSummerTime(prayersToday.asr)),
          PrayerWidget(
              label: "Maghrib", time: toSummerTime(prayersToday.maghrib)),
          PrayerWidget(label: "Isha", time: toSummerTime(prayersToday.isha)),
        ],
      ),
    );
  }
}

class ClockWidget extends StatelessWidget {
  const ClockWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1),
        builder: (context) {
      return Text(
        DateFormat('kk:mm:ss').format(DateTime.now()),
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 48,
        ),
      );
    });
  }
}

class MyCard extends StatefulWidget {
  const MyCard({Key? key, required this.widget}) : super(key: key);

  final Widget widget;

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(180, 0, 0, 0),
      // color: Colors.black54,
      child: Column(
        children: <Widget>[widget.widget],
      ),
    );
  }
}

class PrayerWidget extends StatefulWidget {
  const PrayerWidget({Key? key, required this.label, required this.time})
      : super(key: key);

  final String label;
  final String time;

  @override
  State<PrayerWidget> createState() => PrayerState();
}

class PrayerState extends State<PrayerWidget> {
  @override
  Widget build(BuildContext context) {
    var style = const TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 24,
    );

    return MyCard(
      widget: ListTile(
        leading: Text(
          widget.label,
          style: style,
          textAlign: TextAlign.center,
        ),
        title: const Padding(
          padding: EdgeInsets.all(18.0),
          child: Text(""),
        ),
        trailing: Text(
          widget.time,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
