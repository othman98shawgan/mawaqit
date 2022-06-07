import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:jiffy/jiffy.dart';

import '../prayer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool summerTime = false;

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
    var myData = json.decode(data);
    var d = Jiffy().dayOfYear;
    var today = myData[d];
    var today1 = PrayerModel.fromJson(today);
    int summerTimeAddition = summerTime ? 1 : 0;

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
                    )
                    // ClockWidget(),
                    ),
              ),
            ),
          ),
          PrayerWidget(label: "Fajr", time: toSummerTime(today1.fajr)),
          PrayerWidget(label: "Shuruq", time: toSummerTime(today1.shuruq)),
          PrayerWidget(label: "Duhr", time: toSummerTime(today1.duhr)),
          PrayerWidget(label: "Asr", time: toSummerTime(today1.asr)),
          PrayerWidget(label: "Maghrib", time: toSummerTime(today1.maghrib)),
          PrayerWidget(label: "Isha", time: toSummerTime(today1.isha)),
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

const String data = '''
[
    {
     "Date": "01.01",
     "Fajr": "5:12",
     "Shuruq": "6:36",
     "Duhr": "11:43",
     "Asr": "14:28",
     "Maghrib": "16:53",
     "Isha": "18:13"
    },
    {
     "Date": "01.02",
     "Fajr": "5:12",
     "Shuruq": "6:36",
     "Duhr": "11:43",
     "Asr": "14:29",
     "Maghrib": "16:54",
     "Isha": "18:14"
    },
    {
     "Date": "01.03",
     "Fajr": "5:12",
     "Shuruq": "6:37",
     "Duhr": "11:44",
     "Asr": "14:30",
     "Maghrib": "16:55",
     "Isha": "18:15"
    },
    {
     "Date": "01.04",
     "Fajr": "5:13",
     "Shuruq": "6:37",
     "Duhr": "11:44",
     "Asr": "14:30",
     "Maghrib": "16:55",
     "Isha": "18:15"
    },
    {
     "Date": "01.05",
     "Fajr": "5:13",
     "Shuruq": "6:37",
     "Duhr": "11:44",
     "Asr": "14:31",
     "Maghrib": "16:56",
     "Isha": "18:16"
    },
    {
     "Date": "01.06",
     "Fajr": "5:13",
     "Shuruq": "6:37",
     "Duhr": "11:45",
     "Asr": "14:32",
     "Maghrib": "16:57",
     "Isha": "18:17"
    },
    {
     "Date": "01.07",
     "Fajr": "5:13",
     "Shuruq": "6:37",
     "Duhr": "11:45",
     "Asr": "14:32",
     "Maghrib": "16:58",
     "Isha": "18:17"
    },
    {
     "Date": "01.08",
     "Fajr": "5:13",
     "Shuruq": "6:37",
     "Duhr": "11:46",
     "Asr": "14:33",
     "Maghrib": "16:59",
     "Isha": "18:18"
    },
    {
     "Date": "01.09",
     "Fajr": "5:13",
     "Shuruq": "6:37",
     "Duhr": "11:46",
     "Asr": "14:34",
     "Maghrib": "16:59",
     "Isha": "18:19"
    },
    {
     "Date": "01.10",
     "Fajr": "5:13",
     "Shuruq": "6:37",
     "Duhr": "11:47",
     "Asr": "14:35",
     "Maghrib": "17:00",
     "Isha": "18:20"
    },
    {
     "Date": "01.11",
     "Fajr": "5:13",
     "Shuruq": "6:37",
     "Duhr": "11:47",
     "Asr": "14:35",
     "Maghrib": "17:01",
     "Isha": "18:20"
    },
    {
     "Date": "01.12",
     "Fajr": "5:13",
     "Shuruq": "6:37",
     "Duhr": "11:47",
     "Asr": "14:36",
     "Maghrib": "17:02",
     "Isha": "18:21"
    },
    {
     "Date": "01.13",
     "Fajr": "5:13",
     "Shuruq": "6:37",
     "Duhr": "11:48",
     "Asr": "14:37",
     "Maghrib": "17:03",
     "Isha": "18:22"
    },
    {
     "Date": "01.14",
     "Fajr": "5:13",
     "Shuruq": "6:36",
     "Duhr": "11:48",
     "Asr": "14:38",
     "Maghrib": "17:04",
     "Isha": "18:23"
    },
    {
     "Date": "01.15",
     "Fajr": "5:13",
     "Shuruq": "6:36",
     "Duhr": "11:48",
     "Asr": "14:39",
     "Maghrib": "17:04",
     "Isha": "18:23"
    },
    {
     "Date": "01.16",
     "Fajr": "5:13",
     "Shuruq": "6:36",
     "Duhr": "11:49",
     "Asr": "14:39",
     "Maghrib": "17:05",
     "Isha": "18:24"
    },
    {
     "Date": "01.17",
     "Fajr": "5:13",
     "Shuruq": "6:36",
     "Duhr": "11:49",
     "Asr": "14:40",
     "Maghrib": "17:06",
     "Isha": "18:25"
    },
    {
     "Date": "01.18",
     "Fajr": "5:13",
     "Shuruq": "6:35",
     "Duhr": "11:49",
     "Asr": "14:41",
     "Maghrib": "17:07",
     "Isha": "18:26"
    },
    {
     "Date": "01.19",
     "Fajr": "5:13",
     "Shuruq": "6:35",
     "Duhr": "11:50",
     "Asr": "14:42",
     "Maghrib": "17:08",
     "Isha": "18:26"
    },
    {
     "Date": "01.20",
     "Fajr": "5:13",
     "Shuruq": "6:35",
     "Duhr": "11:50",
     "Asr": "14:42",
     "Maghrib": "17:09",
     "Isha": "18:27"
    },
    {
     "Date": "01.21",
     "Fajr": "5:12",
     "Shuruq": "6:35",
     "Duhr": "11:50",
     "Asr": "14:43",
     "Maghrib": "17:10",
     "Isha": "18:28"
    },
    {
     "Date": "01.22",
     "Fajr": "5:12",
     "Shuruq": "6:34",
     "Duhr": "11:50",
     "Asr": "14:44",
     "Maghrib": "17:11",
     "Isha": "18:29"
    },
    {
     "Date": "01.23",
     "Fajr": "5:12",
     "Shuruq": "6:34",
     "Duhr": "11:51",
     "Asr": "14:45",
     "Maghrib": "17:11",
     "Isha": "18:30"
    },
    {
     "Date": "01.24",
     "Fajr": "5:12",
     "Shuruq": "6:34",
     "Duhr": "11:51",
     "Asr": "14:46",
     "Maghrib": "17:12",
     "Isha": "18:30"
    },
    {
     "Date": "01.25",
     "Fajr": "5:11",
     "Shuruq": "6:33",
     "Duhr": "11:51",
     "Asr": "14:46",
     "Maghrib": "17:13",
     "Isha": "18:31"
    },
    {
     "Date": "01.26",
     "Fajr": "5:11",
     "Shuruq": "6:32",
     "Duhr": "11:51",
     "Asr": "14:47",
     "Maghrib": "17:14",
     "Isha": "18:32"
    },
    {
     "Date": "01.27",
     "Fajr": "5:11",
     "Shuruq": "6:32",
     "Duhr": "11:52",
     "Asr": "14:48",
     "Maghrib": "17:15",
     "Isha": "18:33"
    },
    {
     "Date": "01.28",
     "Fajr": "5:10",
     "Shuruq": "6:32",
     "Duhr": "11:52",
     "Asr": "14:49",
     "Maghrib": "17:16",
     "Isha": "18:33"
    },
    {
     "Date": "01.29",
     "Fajr": "5:10",
     "Shuruq": "6:31",
     "Duhr": "11:52",
     "Asr": "14:49",
     "Maghrib": "17:17",
     "Isha": "18:34"
    },
    {
     "Date": "01.30",
     "Fajr": "5:09",
     "Shuruq": "6:31",
     "Duhr": "11:52",
     "Asr": "14:50",
     "Maghrib": "17:18",
     "Isha": "18:35"
    },
    {
     "Date": "01.31",
     "Fajr": "5:09",
     "Shuruq": "6:30",
     "Duhr": "11:52",
     "Asr": "14:51",
     "Maghrib": "17:18",
     "Isha": "18:36"
    },
    {
     "Date": "02.01",
     "Fajr": "5:08",
     "Shuruq": "6:29",
     "Duhr": "11:52",
     "Asr": "14:52",
     "Maghrib": "17:19",
     "Isha": "18:36"
    },
    {
     "Date": "02.02",
     "Fajr": "5:08",
     "Shuruq": "6:29",
     "Duhr": "11:52",
     "Asr": "14:52",
     "Maghrib": "17:20",
     "Isha": "18:37"
    },
    {
     "Date": "02.03",
     "Fajr": "5:07",
     "Shuruq": "6:28",
     "Duhr": "11:53",
     "Asr": "14:53",
     "Maghrib": "17:21",
     "Isha": "18:38"
    },
    {
     "Date": "02.04",
     "Fajr": "5:06",
     "Shuruq": "6:27",
     "Duhr": "11:53",
     "Asr": "14:54",
     "Maghrib": "17:22",
     "Isha": "18:39"
    },
    {
     "Date": "02.05",
     "Fajr": "5:06",
     "Shuruq": "6:27",
     "Duhr": "11:53",
     "Asr": "14:54",
     "Maghrib": "17:23",
     "Isha": "18:40"
    },
    {
     "Date": "02.06",
     "Fajr": "5:05",
     "Shuruq": "6:26",
     "Duhr": "11:53",
     "Asr": "14:55",
     "Maghrib": "17:24",
     "Isha": "18:40"
    },
    {
     "Date": "02.07",
     "Fajr": "5:05",
     "Shuruq": "6:25",
     "Duhr": "11:53",
     "Asr": "14:56",
     "Maghrib": "17:25",
     "Isha": "18:41"
    },
    {
     "Date": "02.08",
     "Fajr": "5:04",
     "Shuruq": "6:24",
     "Duhr": "11:53",
     "Asr": "14:56",
     "Maghrib": "17:26",
     "Isha": "18:42"
    },
    {
     "Date": "02.09",
     "Fajr": "5:03",
     "Shuruq": "6:23",
     "Duhr": "11:53",
     "Asr": "14:57",
     "Maghrib": "17:26",
     "Isha": "18:43"
    },
    {
     "Date": "02.10",
     "Fajr": "5:02",
     "Shuruq": "6:23",
     "Duhr": "11:53",
     "Asr": "14:58",
     "Maghrib": "17:27",
     "Isha": "18:43"
    },
    {
     "Date": "02.11",
     "Fajr": "5:02",
     "Shuruq": "6:22",
     "Duhr": "11:53",
     "Asr": "14:58",
     "Maghrib": "17:28",
     "Isha": "18:44"
    },
    {
     "Date": "02.12",
     "Fajr": "5:01",
     "Shuruq": "6:21",
     "Duhr": "11:53",
     "Asr": "14:59",
     "Maghrib": "17:29",
     "Isha": "18:45"
    },
    {
     "Date": "02.13",
     "Fajr": "5:00",
     "Shuruq": "6:20",
     "Duhr": "11:53",
     "Asr": "15:00",
     "Maghrib": "17:30",
     "Isha": "18:46"
    },
    {
     "Date": "02.14",
     "Fajr": "4:59",
     "Shuruq": "6:19",
     "Duhr": "11:53",
     "Asr": "15:00",
     "Maghrib": "17:31",
     "Isha": "18:46"
    },
    {
     "Date": "02.15",
     "Fajr": "4:58",
     "Shuruq": "6:18",
     "Duhr": "11:53",
     "Asr": "15:01",
     "Maghrib": "17:31",
     "Isha": "18:47"
    },
    {
     "Date": "02.16",
     "Fajr": "4:57",
     "Shuruq": "6:17",
     "Duhr": "11:53",
     "Asr": "15:01",
     "Maghrib": "17:32",
     "Isha": "18:48"
    },
    {
     "Date": "02.17",
     "Fajr": "4:57",
     "Shuruq": "6:16",
     "Duhr": "11:53",
     "Asr": "15:02",
     "Maghrib": "17:33",
     "Isha": "18:49"
    },
    {
     "Date": "02.18",
     "Fajr": "4:56",
     "Shuruq": "6:15",
     "Duhr": "11:53",
     "Asr": "15:03",
     "Maghrib": "17:34",
     "Isha": "18:49"
    },
    {
     "Date": "02.19",
     "Fajr": "4:55",
     "Shuruq": "6:14",
     "Duhr": "11:52",
     "Asr": "15:03",
     "Maghrib": "17:35",
     "Isha": "18:50"
    },
    {
     "Date": "02.20",
     "Fajr": "4:54",
     "Shuruq": "6:13",
     "Duhr": "11:52",
     "Asr": "15:04",
     "Maghrib": "17:36",
     "Isha": "18:51"
    },
    {
     "Date": "02.21",
     "Fajr": "4:53",
     "Shuruq": "6:12",
     "Duhr": "11:52",
     "Asr": "15:04",
     "Maghrib": "17:36",
     "Isha": "18:52"
    },
    {
     "Date": "02.22",
     "Fajr": "4:52",
     "Shuruq": "6:11",
     "Duhr": "11:52",
     "Asr": "15:05",
     "Maghrib": "17:37",
     "Isha": "18:52"
    },
    {
     "Date": "02.23",
     "Fajr": "4:51",
     "Shuruq": "6:10",
     "Duhr": "11:52",
     "Asr": "15:05",
     "Maghrib": "17:38",
     "Isha": "18:53"
    },
    {
     "Date": "02.24",
     "Fajr": "4:50",
     "Shuruq": "6:09",
     "Duhr": "11:52",
     "Asr": "15:06",
     "Maghrib": "17:39",
     "Isha": "18:54"
    },
    {
     "Date": "02.25",
     "Fajr": "4:49",
     "Shuruq": "6:08",
     "Duhr": "11:52",
     "Asr": "15:06",
     "Maghrib": "17:40",
     "Isha": "18:55"
    },
    {
     "Date": "02.26",
     "Fajr": "4:48",
     "Shuruq": "6:07",
     "Duhr": "11:51",
     "Asr": "15:07",
     "Maghrib": "17:40",
     "Isha": "18:55"
    },
    {
     "Date": "02.27",
     "Fajr": "4:46",
     "Shuruq": "6:05",
     "Duhr": "11:51",
     "Asr": "15:07",
     "Maghrib": "17:41",
     "Isha": "18:56"
    },
    {
     "Date": "02.28",
     "Fajr": "4:46",
     "Shuruq": "6:05",
     "Duhr": "11:51",
     "Asr": "15:07",
     "Maghrib": "17:41",
     "Isha": "18:56"
    },
    {
     "Date": "02.29",
     "Fajr": "4:46",
     "Shuruq": "6:05",
     "Duhr": "11:51",
     "Asr": "15:07",
     "Maghrib": "17:42",
     "Isha": "18:56"
    },
    {
     "Date": "03.01",
     "Fajr": "4:44",
     "Shuruq": "6:03",
     "Duhr": "11:51",
     "Asr": "15:08",
     "Maghrib": "17:43",
     "Isha": "18:58"
    },
    {
     "Date": "03.02",
     "Fajr": "4:43",
     "Shuruq": "6:02",
     "Duhr": "11:51",
     "Asr": "15:08",
     "Maghrib": "17:44",
     "Isha": "18:58"
    },
    {
     "Date": "03.03",
     "Fajr": "4:42",
     "Shuruq": "6:01",
     "Duhr": "11:51",
     "Asr": "15:09",
     "Maghrib": "17:44",
     "Isha": "18:59"
    },
    {
     "Date": "03.04",
     "Fajr": "4:41",
     "Shuruq": "6:00",
     "Duhr": "11:50",
     "Asr": "15:09",
     "Maghrib": "17:45",
     "Isha": "19:00"
    },
    {
     "Date": "03.05",
     "Fajr": "4:40",
     "Shuruq": "5:58",
     "Duhr": "11:50",
     "Asr": "15:10",
     "Maghrib": "17:46",
     "Isha": "19:01"
    },
    {
     "Date": "03.06",
     "Fajr": "4:38",
     "Shuruq": "5:57",
     "Duhr": "11:50",
     "Asr": "15:10",
     "Maghrib": "17:47",
     "Isha": "19:01"
    },
    {
     "Date": "03.07",
     "Fajr": "4:37",
     "Shuruq": "5:56",
     "Duhr": "11:50",
     "Asr": "15:10",
     "Maghrib": "17:47",
     "Isha": "19:02"
    },
    {
     "Date": "03.08",
     "Fajr": "4:36",
     "Shuruq": "5:55",
     "Duhr": "11:49",
     "Asr": "15:11",
     "Maghrib": "17:48",
     "Isha": "19:03"
    },
    {
     "Date": "03.09",
     "Fajr": "4:35",
     "Shuruq": "5:54",
     "Duhr": "11:49",
     "Asr": "15:11",
     "Maghrib": "17:49",
     "Isha": "19:04"
    },
    {
     "Date": "03.10",
     "Fajr": "4:34",
     "Shuruq": "5:53",
     "Duhr": "11:49",
     "Asr": "15:11",
     "Maghrib": "17:50",
     "Isha": "19:04"
    },
    {
     "Date": "03.11",
     "Fajr": "4:33",
     "Shuruq": "5:51",
     "Duhr": "11:49",
     "Asr": "15:12",
     "Maghrib": "17:50",
     "Isha": "19:05"
    },
    {
     "Date": "03.12",
     "Fajr": "4:31",
     "Shuruq": "5:50",
     "Duhr": "11:48",
     "Asr": "15:12",
     "Maghrib": "17:51",
     "Isha": "19:06"
    },
    {
     "Date": "03.13",
     "Fajr": "4:30",
     "Shuruq": "5:49",
     "Duhr": "11:48",
     "Asr": "15:12",
     "Maghrib": "17:52",
     "Isha": "19:07"
    },
    {
     "Date": "03.14",
     "Fajr": "4:28",
     "Shuruq": "5:47",
     "Duhr": "11:48",
     "Asr": "15:12",
     "Maghrib": "17:53",
     "Isha": "19:08"
    },
    {
     "Date": "03.15",
     "Fajr": "4:27",
     "Shuruq": "5:46",
     "Duhr": "11:48",
     "Asr": "15:13",
     "Maghrib": "17:53",
     "Isha": "19:08"
    },
    {
     "Date": "03.16",
     "Fajr": "4:26",
     "Shuruq": "5:45",
     "Duhr": "11:47",
     "Asr": "15:13",
     "Maghrib": "17:54",
     "Isha": "19:09"
    },
    {
     "Date": "03.17",
     "Fajr": "4:24",
     "Shuruq": "5:43",
     "Duhr": "11:47",
     "Asr": "15:13",
     "Maghrib": "17:55",
     "Isha": "19:10"
    },
    {
     "Date": "03.18",
     "Fajr": "4:23",
     "Shuruq": "5:42",
     "Duhr": "11:47",
     "Asr": "15:14",
     "Maghrib": "17:55",
     "Isha": "19:11"
    },
    {
     "Date": "03.19",
     "Fajr": "4:22",
     "Shuruq": "5:41",
     "Duhr": "11:46",
     "Asr": "15:14",
     "Maghrib": "17:56",
     "Isha": "19:11"
    },
    {
     "Date": "03.20",
     "Fajr": "4:20",
     "Shuruq": "5:40",
     "Duhr": "11:46",
     "Asr": "15:14",
     "Maghrib": "17:57",
     "Isha": "19:12"
    },
    {
     "Date": "03.21",
     "Fajr": "4:19",
     "Shuruq": "5:38",
     "Duhr": "11:46",
     "Asr": "15:14",
     "Maghrib": "17:58",
     "Isha": "19:13"
    },
    {
     "Date": "03.22",
     "Fajr": "4:17",
     "Shuruq": "5:37",
     "Duhr": "11:46",
     "Asr": "15:14",
     "Maghrib": "17:58",
     "Isha": "19:14"
    },
    {
     "Date": "03.23",
     "Fajr": "4:16",
     "Shuruq": "5:36",
     "Duhr": "11:45",
     "Asr": "15:14",
     "Maghrib": "17:59",
     "Isha": "19:14"
    },
    {
     "Date": "03.24",
     "Fajr": "4:15",
     "Shuruq": "5:34",
     "Duhr": "11:45",
     "Asr": "15:14",
     "Maghrib": "18:00",
     "Isha": "19:15"
    },
    {
     "Date": "03.25",
     "Fajr": "4:13",
     "Shuruq": "5:33",
     "Duhr": "11:45",
     "Asr": "15:15",
     "Maghrib": "18:00",
     "Isha": "19:16"
    },
    {
     "Date": "03.26",
     "Fajr": "4:12",
     "Shuruq": "5:32",
     "Duhr": "11:44",
     "Asr": "15:15",
     "Maghrib": "18:01",
     "Isha": "19:17"
    },
    {
     "Date": "03.27",
     "Fajr": "4:10",
     "Shuruq": "5:30",
     "Duhr": "11:44",
     "Asr": "15:15",
     "Maghrib": "18:02",
     "Isha": "19:18"
    },
    {
     "Date": "03.28",
     "Fajr": "4:09",
     "Shuruq": "5:29",
     "Duhr": "11:44",
     "Asr": "15:15",
     "Maghrib": "18:02",
     "Isha": "19:19"
    },
    {
     "Date": "03.29",
     "Fajr": "4:08",
     "Shuruq": "5:28",
     "Duhr": "11:43",
     "Asr": "15:15",
     "Maghrib": "18:03",
     "Isha": "19:19"
    },
    {
     "Date": "03.30",
     "Fajr": "4:06",
     "Shuruq": "5:27",
     "Duhr": "11:43",
     "Asr": "15:15",
     "Maghrib": "18:04",
     "Isha": "19:20"
    },
    {
     "Date": "03.31",
     "Fajr": "4:05",
     "Shuruq": "5:25",
     "Duhr": "11:43",
     "Asr": "15:15",
     "Maghrib": "18:05",
     "Isha": "19:21"
    },
    {
     "Date": "04.01",
     "Fajr": "4:03",
     "Shuruq": "5:24",
     "Duhr": "11:43",
     "Asr": "15:15",
     "Maghrib": "18:05",
     "Isha": "19:22"
    },
    {
     "Date": "04.02",
     "Fajr": "4:02",
     "Shuruq": "5:23",
     "Duhr": "11:42",
     "Asr": "15:15",
     "Maghrib": "18:06",
     "Isha": "19:23"
    },
    {
     "Date": "04.03",
     "Fajr": "4:00",
     "Shuruq": "5:21",
     "Duhr": "11:42",
     "Asr": "15:15",
     "Maghrib": "18:07",
     "Isha": "19:24"
    },
    {
     "Date": "04.04",
     "Fajr": "3:59",
     "Shuruq": "5:20",
     "Duhr": "11:42",
     "Asr": "15:16",
     "Maghrib": "18:07",
     "Isha": "19:24"
    },
    {
     "Date": "04.05",
     "Fajr": "3:58",
     "Shuruq": "5:19",
     "Duhr": "11:41",
     "Asr": "15:16",
     "Maghrib": "18:08",
     "Isha": "19:25"
    },
    {
     "Date": "04.06",
     "Fajr": "3:56",
     "Shuruq": "5:18",
     "Duhr": "11:41",
     "Asr": "15:16",
     "Maghrib": "18:09",
     "Isha": "19:26"
    },
    {
     "Date": "04.07",
     "Fajr": "3:55",
     "Shuruq": "5:16",
     "Duhr": "11:41",
     "Asr": "15:16",
     "Maghrib": "18:09",
     "Isha": "19:27"
    },
    {
     "Date": "04.08",
     "Fajr": "3:53",
     "Shuruq": "5:15",
     "Duhr": "11:41",
     "Asr": "15:16",
     "Maghrib": "18:10",
     "Isha": "19:28"
    },
    {
     "Date": "04.09",
     "Fajr": "3:52",
     "Shuruq": "5:14",
     "Duhr": "11:40",
     "Asr": "15:16",
     "Maghrib": "18:11",
     "Isha": "19:29"
    },
    {
     "Date": "04.10",
     "Fajr": "3:50",
     "Shuruq": "5:13",
     "Duhr": "11:40",
     "Asr": "15:16",
     "Maghrib": "18:11",
     "Isha": "19:30"
    },
    {
     "Date": "04.11",
     "Fajr": "3:49",
     "Shuruq": "5:11",
     "Duhr": "11:40",
     "Asr": "15:16",
     "Maghrib": "18:12",
     "Isha": "19:30"
    },
    {
     "Date": "04.12",
     "Fajr": "3:48",
     "Shuruq": "5:10",
     "Duhr": "11:39",
     "Asr": "15:16",
     "Maghrib": "18:13",
     "Isha": "19:31"
    },
    {
     "Date": "04.13",
     "Fajr": "3:46",
     "Shuruq": "5:09",
     "Duhr": "11:39",
     "Asr": "15:16",
     "Maghrib": "18:13",
     "Isha": "19:32"
    },
    {
     "Date": "04.14",
     "Fajr": "3:45",
     "Shuruq": "5:08",
     "Duhr": "11:39",
     "Asr": "15:16",
     "Maghrib": "18:14",
     "Isha": "19:33"
    },
    {
     "Date": "04.15",
     "Fajr": "3:43",
     "Shuruq": "5:07",
     "Duhr": "11:39",
     "Asr": "15:16",
     "Maghrib": "18:15",
     "Isha": "19:34"
    },
    {
     "Date": "04.16",
     "Fajr": "3:42",
     "Shuruq": "5:05",
     "Duhr": "11:39",
     "Asr": "15:16",
     "Maghrib": "18:16",
     "Isha": "19:35"
    },
    {
     "Date": "04.17",
     "Fajr": "3:41",
     "Shuruq": "5:04",
     "Duhr": "11:38",
     "Asr": "15:16",
     "Maghrib": "18:16",
     "Isha": "19:36"
    },
    {
     "Date": "04.18",
     "Fajr": "3:39",
     "Shuruq": "5:03",
     "Duhr": "11:38",
     "Asr": "15:16",
     "Maghrib": "18:17",
     "Isha": "19:37"
    },
    {
     "Date": "04.19",
     "Fajr": "3:38",
     "Shuruq": "5:02",
     "Duhr": "11:38",
     "Asr": "15:16",
     "Maghrib": "18:18",
     "Isha": "19:38"
    },
    {
     "Date": "04.20",
     "Fajr": "3:36",
     "Shuruq": "5:01",
     "Duhr": "11:38",
     "Asr": "15:16",
     "Maghrib": "18:18",
     "Isha": "19:39"
    },
    {
     "Date": "04.21",
     "Fajr": "3:35",
     "Shuruq": "5:00",
     "Duhr": "11:37",
     "Asr": "15:16",
     "Maghrib": "18:19",
     "Isha": "19:40"
    },
    {
     "Date": "04.22",
     "Fajr": "3:34",
     "Shuruq": "4:59",
     "Duhr": "11:37",
     "Asr": "15:16",
     "Maghrib": "18:20",
     "Isha": "19:41"
    },
    {
     "Date": "04.23",
     "Fajr": "3:32",
     "Shuruq": "4:58",
     "Duhr": "11:37",
     "Asr": "15:16",
     "Maghrib": "18:20",
     "Isha": "19:41"
    },
    {
     "Date": "04.24",
     "Fajr": "3:31",
     "Shuruq": "4:57",
     "Duhr": "11:37",
     "Asr": "15:16",
     "Maghrib": "18:21",
     "Isha": "19:42"
    },
    {
     "Date": "04.25",
     "Fajr": "3:30",
     "Shuruq": "4:55",
     "Duhr": "11:37",
     "Asr": "15:16",
     "Maghrib": "18:22",
     "Isha": "19:43"
    },
    {
     "Date": "04.26",
     "Fajr": "3:29",
     "Shuruq": "4:54",
     "Duhr": "11:36",
     "Asr": "15:15",
     "Maghrib": "18:22",
     "Isha": "19:44"
    },
    {
     "Date": "04.27",
     "Fajr": "3:27",
     "Shuruq": "4:53",
     "Duhr": "11:36",
     "Asr": "15:15",
     "Maghrib": "18:23",
     "Isha": "19:45"
    },
    {
     "Date": "04.28",
     "Fajr": "3:26",
     "Shuruq": "4:52",
     "Duhr": "11:36",
     "Asr": "15:15",
     "Maghrib": "18:24",
     "Isha": "19:46"
    },
    {
     "Date": "04.29",
     "Fajr": "3:25",
     "Shuruq": "4:51",
     "Duhr": "11:36",
     "Asr": "15:15",
     "Maghrib": "18:25",
     "Isha": "19:47"
    },
    {
     "Date": "04.30",
     "Fajr": "3:24",
     "Shuruq": "4:50",
     "Duhr": "11:36",
     "Asr": "15:15",
     "Maghrib": "18:25",
     "Isha": "19:48"
    },
    {
     "Date": "05.01",
     "Fajr": "3:22",
     "Shuruq": "4:50",
     "Duhr": "11:36",
     "Asr": "15:15",
     "Maghrib": "18:26",
     "Isha": "19:49"
    },
    {
     "Date": "05.02",
     "Fajr": "3:21",
     "Shuruq": "4:49",
     "Duhr": "11:36",
     "Asr": "15:15",
     "Maghrib": "18:27",
     "Isha": "19:50"
    },
    {
     "Date": "05.03",
     "Fajr": "3:20",
     "Shuruq": "4:48",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:27",
     "Isha": "19:51"
    },
    {
     "Date": "05.04",
     "Fajr": "3:19",
     "Shuruq": "4:47",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:28",
     "Isha": "19:52"
    },
    {
     "Date": "05.05",
     "Fajr": "3:18",
     "Shuruq": "4:46",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:29",
     "Isha": "19:53"
    },
    {
     "Date": "05.06",
     "Fajr": "3:16",
     "Shuruq": "4:45",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:29",
     "Isha": "19:54"
    },
    {
     "Date": "05.07",
     "Fajr": "3:15",
     "Shuruq": "4:44",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:30",
     "Isha": "19:55"
    },
    {
     "Date": "05.08",
     "Fajr": "3:14",
     "Shuruq": "4:43",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:31",
     "Isha": "19:56"
    },
    {
     "Date": "05.09",
     "Fajr": "3:13",
     "Shuruq": "4:43",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:31",
     "Isha": "19:57"
    },
    {
     "Date": "05.10",
     "Fajr": "3:12",
     "Shuruq": "4:42",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:32",
     "Isha": "19:58"
    },
    {
     "Date": "05.11",
     "Fajr": "3:11",
     "Shuruq": "4:41",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:33",
     "Isha": "19:59"
    },
    {
     "Date": "05.12",
     "Fajr": "3:10",
     "Shuruq": "4:40",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:34",
     "Isha": "20:00"
    },
    {
     "Date": "05.13",
     "Fajr": "3:09",
     "Shuruq": "4:40",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:34",
     "Isha": "20:01"
    },
    {
     "Date": "05.14",
     "Fajr": "3:08",
     "Shuruq": "4:39",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:35",
     "Isha": "20:02"
    },
    {
     "Date": "05.15",
     "Fajr": "3:07",
     "Shuruq": "4:38",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:36",
     "Isha": "20:03"
    },
    {
     "Date": "05.16",
     "Fajr": "3:06",
     "Shuruq": "4:38",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:36",
     "Isha": "20:04"
    },
    {
     "Date": "05.17",
     "Fajr": "3:06",
     "Shuruq": "4:37",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:37",
     "Isha": "20:04"
    },
    {
     "Date": "05.18",
     "Fajr": "3:05",
     "Shuruq": "4:37",
     "Duhr": "11:35",
     "Asr": "15:15",
     "Maghrib": "18:37",
     "Isha": "20:05"
    },
    {
     "Date": "05.19",
     "Fajr": "3:04",
     "Shuruq": "4:36",
     "Duhr": "11:35",
     "Asr": "15:16",
     "Maghrib": "18:38",
     "Isha": "20:06"
    },
    {
     "Date": "05.20",
     "Fajr": "3:03",
     "Shuruq": "4:35",
     "Duhr": "11:35",
     "Asr": "15:16",
     "Maghrib": "18:39",
     "Isha": "20:07"
    },
    {
     "Date": "05.21",
     "Fajr": "3:02",
     "Shuruq": "4:35",
     "Duhr": "11:35",
     "Asr": "15:16",
     "Maghrib": "18:39",
     "Isha": "20:08"
    },
    {
     "Date": "05.22",
     "Fajr": "3:02",
     "Shuruq": "4:34",
     "Duhr": "11:35",
     "Asr": "15:16",
     "Maghrib": "18:40",
     "Isha": "20:09"
    },
    {
     "Date": "05.23",
     "Fajr": "3:01",
     "Shuruq": "4:34",
     "Duhr": "11:35",
     "Asr": "15:16",
     "Maghrib": "18:41",
     "Isha": "20:10"
    },
    {
     "Date": "05.24",
     "Fajr": "3:00",
     "Shuruq": "4:34",
     "Duhr": "11:35",
     "Asr": "15:16",
     "Maghrib": "18:41",
     "Isha": "20:11"
    },
    {
     "Date": "05.25",
     "Fajr": "2:59",
     "Shuruq": "4:33",
     "Duhr": "11:35",
     "Asr": "15:16",
     "Maghrib": "18:42",
     "Isha": "20:11"
    },
    {
     "Date": "05.26",
     "Fajr": "2:59",
     "Shuruq": "4:33",
     "Duhr": "11:36",
     "Asr": "15:16",
     "Maghrib": "18:42",
     "Isha": "20:12"
    },
    {
     "Date": "05.27",
     "Fajr": "2:58",
     "Shuruq": "4:32",
     "Duhr": "11:36",
     "Asr": "15:16",
     "Maghrib": "18:43",
     "Isha": "20:13"
    },
    {
     "Date": "05.28",
     "Fajr": "2:58",
     "Shuruq": "4:32",
     "Duhr": "11:36",
     "Asr": "15:16",
     "Maghrib": "18:44",
     "Isha": "20:14"
    },
    {
     "Date": "05.29",
     "Fajr": "2:57",
     "Shuruq": "4:32",
     "Duhr": "11:36",
     "Asr": "15:16",
     "Maghrib": "18:44",
     "Isha": "20:15"
    },
    {
     "Date": "05.30",
     "Fajr": "2:57",
     "Shuruq": "4:31",
     "Duhr": "11:36",
     "Asr": "15:16",
     "Maghrib": "18:45",
     "Isha": "20:15"
    },
    {
     "Date": "05.31",
     "Fajr": "2:56",
     "Shuruq": "4:31",
     "Duhr": "11:36",
     "Asr": "15:17",
     "Maghrib": "18:45",
     "Isha": "20:16"
    },
    {
     "Date": "06.01",
     "Fajr": "2:56",
     "Shuruq": "4:31",
     "Duhr": "11:36",
     "Asr": "15:17",
     "Maghrib": "18:46",
     "Isha": "20:17"
    },
    {
     "Date": "06.02",
     "Fajr": "2:55",
     "Shuruq": "4:31",
     "Duhr": "11:37",
     "Asr": "15:17",
     "Maghrib": "18:46",
     "Isha": "20:18"
    },
    {
     "Date": "06.03",
     "Fajr": "2:55",
     "Shuruq": "4:30",
     "Duhr": "11:37",
     "Asr": "15:17",
     "Maghrib": "18:47",
     "Isha": "20:18"
    },
    {
     "Date": "06.04",
     "Fajr": "2:55",
     "Shuruq": "4:30",
     "Duhr": "11:37",
     "Asr": "15:17",
     "Maghrib": "18:47",
     "Isha": "20:19"
    },
    {
     "Date": "06.05",
     "Fajr": "2:54",
     "Shuruq": "4:30",
     "Duhr": "11:37",
     "Asr": "15:17",
     "Maghrib": "18:48",
     "Isha": "20:20"
    },
    {
     "Date": "06.06",
     "Fajr": "2:54",
     "Shuruq": "4:30",
     "Duhr": "11:37",
     "Asr": "15:17",
     "Maghrib": "18:48",
     "Isha": "20:20"
    },
    {
     "Date": "06.07",
     "Fajr": "2:54",
     "Shuruq": "4:30",
     "Duhr": "11:37",
     "Asr": "15:18",
     "Maghrib": "18:49",
     "Isha": "20:21"
    },
    {
     "Date": "06.08",
     "Fajr": "2:54",
     "Shuruq": "4:30",
     "Duhr": "11:38",
     "Asr": "15:18",
     "Maghrib": "18:49",
     "Isha": "20:21"
    },
    {
     "Date": "06.09",
     "Fajr": "2:53",
     "Shuruq": "4:30",
     "Duhr": "11:38",
     "Asr": "15:18",
     "Maghrib": "18:50",
     "Isha": "20:22"
    },
    {
     "Date": "06.10",
     "Fajr": "2:53",
     "Shuruq": "4:30",
     "Duhr": "11:38",
     "Asr": "15:18",
     "Maghrib": "18:50",
     "Isha": "20:23"
    },
    {
     "Date": "06.11",
     "Fajr": "2:53",
     "Shuruq": "4:30",
     "Duhr": "11:38",
     "Asr": "15:18",
     "Maghrib": "18:50",
     "Isha": "20:23"
    },
    {
     "Date": "06.12",
     "Fajr": "2:53",
     "Shuruq": "4:30",
     "Duhr": "11:38",
     "Asr": "15:19",
     "Maghrib": "18:51",
     "Isha": "20:24"
    },
    {
     "Date": "06.13",
     "Fajr": "2:53",
     "Shuruq": "4:30",
     "Duhr": "11:39",
     "Asr": "15:19",
     "Maghrib": "18:51",
     "Isha": "20:24"
    },
    {
     "Date": "06.14",
     "Fajr": "2:53",
     "Shuruq": "4:30",
     "Duhr": "11:39",
     "Asr": "15:19",
     "Maghrib": "18:52",
     "Isha": "20:24"
    },
    {
     "Date": "06.15",
     "Fajr": "2:53",
     "Shuruq": "4:30",
     "Duhr": "11:39",
     "Asr": "15:19",
     "Maghrib": "18:52",
     "Isha": "20:25"
    },
    {
     "Date": "06.16",
     "Fajr": "2:53",
     "Shuruq": "4:30",
     "Duhr": "11:39",
     "Asr": "15:19",
     "Maghrib": "18:52",
     "Isha": "20:25"
    },
    {
     "Date": "06.17",
     "Fajr": "2:53",
     "Shuruq": "4:30",
     "Duhr": "11:39",
     "Asr": "15:20",
     "Maghrib": "18:53",
     "Isha": "20:26"
    },
    {
     "Date": "06.18",
     "Fajr": "2:53",
     "Shuruq": "4:30",
     "Duhr": "11:40",
     "Asr": "15:20",
     "Maghrib": "18:53",
     "Isha": "20:26"
    },
    {
     "Date": "06.19",
     "Fajr": "2:54",
     "Shuruq": "4:31",
     "Duhr": "11:40",
     "Asr": "15:20",
     "Maghrib": "18:53",
     "Isha": "20:26"
    },
    {
     "Date": "06.20",
     "Fajr": "2:54",
     "Shuruq": "4:31",
     "Duhr": "11:40",
     "Asr": "15:20",
     "Maghrib": "18:53",
     "Isha": "20:27"
    },
    {
     "Date": "06.21",
     "Fajr": "2:54",
     "Shuruq": "4:31",
     "Duhr": "11:40",
     "Asr": "15:20",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "06.22",
     "Fajr": "2:54",
     "Shuruq": "4:32",
     "Duhr": "11:41",
     "Asr": "15:21",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "06.23",
     "Fajr": "2:55",
     "Shuruq": "4:32",
     "Duhr": "11:41",
     "Asr": "15:21",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "06.24",
     "Fajr": "2:55",
     "Shuruq": "4:32",
     "Duhr": "11:41",
     "Asr": "15:21",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "06.25",
     "Fajr": "2:55",
     "Shuruq": "4:32",
     "Duhr": "11:41",
     "Asr": "15:21",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "06.26",
     "Fajr": "2:56",
     "Shuruq": "4:32",
     "Duhr": "11:41",
     "Asr": "15:21",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "06.27",
     "Fajr": "2:56",
     "Shuruq": "4:33",
     "Duhr": "11:42",
     "Asr": "15:22",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "06.28",
     "Fajr": "2:56",
     "Shuruq": "4:33",
     "Duhr": "11:42",
     "Asr": "15:22",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "06.29",
     "Fajr": "2:57",
     "Shuruq": "4:33",
     "Duhr": "11:42",
     "Asr": "15:22",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "06.30",
     "Fajr": "2:57",
     "Shuruq": "4:34",
     "Duhr": "11:42",
     "Asr": "15:22",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "07.01",
     "Fajr": "2:58",
     "Shuruq": "4:34",
     "Duhr": "11:42",
     "Asr": "15:23",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "07.02",
     "Fajr": "2:58",
     "Shuruq": "4:35",
     "Duhr": "11:43",
     "Asr": "15:23",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "07.03",
     "Fajr": "2:59",
     "Shuruq": "4:35",
     "Duhr": "11:43",
     "Asr": "15:23",
     "Maghrib": "18:54",
     "Isha": "20:27"
    },
    {
     "Date": "07.04",
     "Fajr": "2:59",
     "Shuruq": "4:36",
     "Duhr": "11:43",
     "Asr": "15:23",
     "Maghrib": "18:54",
     "Isha": "20:26"
    },
    {
     "Date": "07.05",
     "Fajr": "3:00",
     "Shuruq": "4:36",
     "Duhr": "11:43",
     "Asr": "15:23",
     "Maghrib": "18:54",
     "Isha": "20:26"
    },
    {
     "Date": "07.06",
     "Fajr": "3:01",
     "Shuruq": "4:36",
     "Duhr": "11:43",
     "Asr": "15:24",
     "Maghrib": "18:54",
     "Isha": "20:26"
    },
    {
     "Date": "07.07",
     "Fajr": "3:01",
     "Shuruq": "4:37",
     "Duhr": "11:43",
     "Asr": "15:24",
     "Maghrib": "18:54",
     "Isha": "20:26"
    },
    {
     "Date": "07.08",
     "Fajr": "3:02",
     "Shuruq": "4:37",
     "Duhr": "11:44",
     "Asr": "15:24",
     "Maghrib": "18:54",
     "Isha": "20:25"
    },
    {
     "Date": "07.09",
     "Fajr": "3:03",
     "Shuruq": "4:38",
     "Duhr": "11:44",
     "Asr": "15:24",
     "Maghrib": "18:54",
     "Isha": "20:25"
    },
    {
     "Date": "07.10",
     "Fajr": "3:03",
     "Shuruq": "4:38",
     "Duhr": "11:44",
     "Asr": "15:24",
     "Maghrib": "18:53",
     "Isha": "20:24"
    },
    {
     "Date": "07.11",
     "Fajr": "3:04",
     "Shuruq": "4:39",
     "Duhr": "11:44",
     "Asr": "15:24",
     "Maghrib": "18:53",
     "Isha": "20:24"
    },
    {
     "Date": "07.12",
     "Fajr": "3:05",
     "Shuruq": "4:40",
     "Duhr": "11:44",
     "Asr": "15:25",
     "Maghrib": "18:53",
     "Isha": "20:24"
    },
    {
     "Date": "07.13",
     "Fajr": "3:06",
     "Shuruq": "4:40",
     "Duhr": "11:44",
     "Asr": "15:25",
     "Maghrib": "18:53",
     "Isha": "20:23"
    },
    {
     "Date": "07.14",
     "Fajr": "3:06",
     "Shuruq": "4:41",
     "Duhr": "11:44",
     "Asr": "15:25",
     "Maghrib": "18:52",
     "Isha": "20:22"
    },
    {
     "Date": "07.15",
     "Fajr": "3:07",
     "Shuruq": "4:41",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:52",
     "Isha": "20:22"
    },
    {
     "Date": "07.16",
     "Fajr": "3:08",
     "Shuruq": "4:42",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:51",
     "Isha": "20:21"
    },
    {
     "Date": "07.17",
     "Fajr": "3:09",
     "Shuruq": "4:42",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:51",
     "Isha": "20:21"
    },
    {
     "Date": "07.18",
     "Fajr": "3:10",
     "Shuruq": "4:43",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:51",
     "Isha": "20:20"
    },
    {
     "Date": "07.19",
     "Fajr": "3:10",
     "Shuruq": "4:44",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:50",
     "Isha": "20:19"
    },
    {
     "Date": "07.20",
     "Fajr": "3:11",
     "Shuruq": "4:44",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:50",
     "Isha": "20:19"
    },
    {
     "Date": "07.21",
     "Fajr": "3:12",
     "Shuruq": "4:45",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:49",
     "Isha": "20:18"
    },
    {
     "Date": "07.22",
     "Fajr": "3:13",
     "Shuruq": "4:45",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:49",
     "Isha": "20:17"
    },
    {
     "Date": "07.23",
     "Fajr": "3:14",
     "Shuruq": "4:46",
     "Duhr": "11:45",
     "Asr": "15:26",
     "Maghrib": "18:48",
     "Isha": "20:16"
    },
    {
     "Date": "07.24",
     "Fajr": "3:15",
     "Shuruq": "4:47",
     "Duhr": "11:45",
     "Asr": "15:26",
     "Maghrib": "18:48",
     "Isha": "20:15"
    },
    {
     "Date": "07.25",
     "Fajr": "3:16",
     "Shuruq": "4:47",
     "Duhr": "11:45",
     "Asr": "15:26",
     "Maghrib": "18:47",
     "Isha": "20:15"
    },
    {
     "Date": "07.26",
     "Fajr": "3:17",
     "Shuruq": "4:48",
     "Duhr": "11:45",
     "Asr": "15:26",
     "Maghrib": "18:46",
     "Isha": "20:14"
    },
    {
     "Date": "07.27",
     "Fajr": "3:17",
     "Shuruq": "4:49",
     "Duhr": "11:45",
     "Asr": "15:26",
     "Maghrib": "18:46",
     "Isha": "20:13"
    },
    {
     "Date": "07.28",
     "Fajr": "3:18",
     "Shuruq": "4:49",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:45",
     "Isha": "20:12"
    },
    {
     "Date": "07.29",
     "Fajr": "3:19",
     "Shuruq": "4:50",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:44",
     "Isha": "20:11"
    },
    {
     "Date": "07.30",
     "Fajr": "3:20",
     "Shuruq": "4:50",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:44",
     "Isha": "20:10"
    },
    {
     "Date": "07.31",
     "Fajr": "3:21",
     "Shuruq": "4:51",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:43",
     "Isha": "20:09"
    },
    {
     "Date": "08.01",
     "Fajr": "3:22",
     "Shuruq": "4:52",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:42",
     "Isha": "20:08"
    },
    {
     "Date": "08.02",
     "Fajr": "3:23",
     "Shuruq": "4:52",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:41",
     "Isha": "20:07"
    },
    {
     "Date": "08.03",
     "Fajr": "3:24",
     "Shuruq": "4:53",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:41",
     "Isha": "20:06"
    },
    {
     "Date": "08.04",
     "Fajr": "3:25",
     "Shuruq": "4:54",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:40",
     "Isha": "20:05"
    },
    {
     "Date": "08.05",
     "Fajr": "3:26",
     "Shuruq": "4:54",
     "Duhr": "11:45",
     "Asr": "15:25",
     "Maghrib": "18:39",
     "Isha": "20:03"
    },
    {
     "Date": "08.06",
     "Fajr": "3:27",
     "Shuruq": "4:55",
     "Duhr": "11:45",
     "Asr": "15:24",
     "Maghrib": "18:38",
     "Isha": "20:02"
    },
    {
     "Date": "08.07",
     "Fajr": "3:28",
     "Shuruq": "4:56",
     "Duhr": "11:44",
     "Asr": "15:24",
     "Maghrib": "18:37",
     "Isha": "20:01"
    },
    {
     "Date": "08.08",
     "Fajr": "3:29",
     "Shuruq": "4:56",
     "Duhr": "11:44",
     "Asr": "15:24",
     "Maghrib": "18:36",
     "Isha": "20:00"
    },
    {
     "Date": "08.09",
     "Fajr": "3:29",
     "Shuruq": "4:57",
     "Duhr": "11:44",
     "Asr": "15:24",
     "Maghrib": "18:35",
     "Isha": "19:59"
    },
    {
     "Date": "08.10",
     "Fajr": "3:30",
     "Shuruq": "4:58",
     "Duhr": "11:44",
     "Asr": "15:24",
     "Maghrib": "18:34",
     "Isha": "19:58"
    },
    {
     "Date": "08.11",
     "Fajr": "3:31",
     "Shuruq": "4:58",
     "Duhr": "11:44",
     "Asr": "15:23",
     "Maghrib": "18:33",
     "Isha": "19:56"
    },
    {
     "Date": "08.12",
     "Fajr": "3:32",
     "Shuruq": "4:59",
     "Duhr": "11:44",
     "Asr": "15:23",
     "Maghrib": "18:32",
     "Isha": "19:55"
    },
    {
     "Date": "08.13",
     "Fajr": "3:33",
     "Shuruq": "5:00",
     "Duhr": "11:44",
     "Asr": "15:23",
     "Maghrib": "18:31",
     "Isha": "19:54"
    },
    {
     "Date": "08.14",
     "Fajr": "3:34",
     "Shuruq": "5:00",
     "Duhr": "11:43",
     "Asr": "15:23",
     "Maghrib": "18:30",
     "Isha": "19:53"
    },
    {
     "Date": "08.15",
     "Fajr": "3:35",
     "Shuruq": "5:01",
     "Duhr": "11:43",
     "Asr": "15:22",
     "Maghrib": "18:29",
     "Isha": "19:51"
    },
    {
     "Date": "08.16",
     "Fajr": "3:36",
     "Shuruq": "5:02",
     "Duhr": "11:43",
     "Asr": "15:22",
     "Maghrib": "18:28",
     "Isha": "19:50"
    },
    {
     "Date": "08.17",
     "Fajr": "3:37",
     "Shuruq": "5:02",
     "Duhr": "11:43",
     "Asr": "15:21",
     "Maghrib": "18:27",
     "Isha": "19:49"
    },
    {
     "Date": "08.18",
     "Fajr": "3:38",
     "Shuruq": "5:03",
     "Duhr": "11:43",
     "Asr": "15:21",
     "Maghrib": "18:26",
     "Isha": "19:47"
    },
    {
     "Date": "08.19",
     "Fajr": "3:39",
     "Shuruq": "5:04",
     "Duhr": "11:42",
     "Asr": "15:21",
     "Maghrib": "18:25",
     "Isha": "19:46"
    },
    {
     "Date": "08.20",
     "Fajr": "3:39",
     "Shuruq": "5:04",
     "Duhr": "11:42",
     "Asr": "15:20",
     "Maghrib": "18:24",
     "Isha": "19:45"
    },
    {
     "Date": "08.21",
     "Fajr": "3:40",
     "Shuruq": "5:05",
     "Duhr": "11:42",
     "Asr": "15:20",
     "Maghrib": "18:23",
     "Isha": "19:43"
    },
    {
     "Date": "08.22",
     "Fajr": "3:41",
     "Shuruq": "5:05",
     "Duhr": "11:42",
     "Asr": "15:19",
     "Maghrib": "18:22",
     "Isha": "19:42"
    },
    {
     "Date": "08.23",
     "Fajr": "3:42",
     "Shuruq": "5:06",
     "Duhr": "11:41",
     "Asr": "15:19",
     "Maghrib": "18:21",
     "Isha": "19:40"
    },
    {
     "Date": "08.24",
     "Fajr": "3:43",
     "Shuruq": "5:07",
     "Duhr": "11:41",
     "Asr": "15:19",
     "Maghrib": "18:19",
     "Isha": "19:39"
    },
    {
     "Date": "08.25",
     "Fajr": "3:44",
     "Shuruq": "5:07",
     "Duhr": "11:41",
     "Asr": "15:18",
     "Maghrib": "18:18",
     "Isha": "19:38"
    },
    {
     "Date": "08.26",
     "Fajr": "3:45",
     "Shuruq": "5:08",
     "Duhr": "11:40",
     "Asr": "15:18",
     "Maghrib": "18:17",
     "Isha": "19:36"
    },
    {
     "Date": "08.27",
     "Fajr": "3:46",
     "Shuruq": "5:09",
     "Duhr": "11:40",
     "Asr": "15:17",
     "Maghrib": "18:16",
     "Isha": "19:35"
    },
    {
     "Date": "08.28",
     "Fajr": "3:46",
     "Shuruq": "5:09",
     "Duhr": "11:40",
     "Asr": "15:17",
     "Maghrib": "18:15",
     "Isha": "19:33"
    },
    {
     "Date": "08.29",
     "Fajr": "3:47",
     "Shuruq": "5:10",
     "Duhr": "11:40",
     "Asr": "15:16",
     "Maghrib": "18:13",
     "Isha": "19:32"
    },
    {
     "Date": "08.30",
     "Fajr": "3:48",
     "Shuruq": "5:11",
     "Duhr": "10:39",
     "Asr": "15:15",
     "Maghrib": "18:12",
     "Isha": "19:31"
    },
    {
     "Date": "08.31",
     "Fajr": "3:49",
     "Shuruq": "5:11",
     "Duhr": "10:39",
     "Asr": "15:15",
     "Maghrib": "18:11",
     "Isha": "19:29"
    },
    {
     "Date": "09.01",
     "Fajr": "3:50",
     "Shuruq": "5:12",
     "Duhr": "11:39",
     "Asr": "15:14",
     "Maghrib": "18:10",
     "Isha": "19:28"
    },
    {
     "Date": "09.02",
     "Fajr": "3:51",
     "Shuruq": "5:12",
     "Duhr": "11:38",
     "Asr": "15:14",
     "Maghrib": "18:08",
     "Isha": "19:26"
    },
    {
     "Date": "09.03",
     "Fajr": "3:51",
     "Shuruq": "5:13",
     "Duhr": "11:38",
     "Asr": "15:13",
     "Maghrib": "18:07",
     "Isha": "19:25"
    },
    {
     "Date": "09.04",
     "Fajr": "3:52",
     "Shuruq": "5:14",
     "Duhr": "11:38",
     "Asr": "15:12",
     "Maghrib": "18:06",
     "Isha": "19:23"
    },
    {
     "Date": "09.05",
     "Fajr": "3:53",
     "Shuruq": "5:14",
     "Duhr": "11:37",
     "Asr": "15:12",
     "Maghrib": "18:04",
     "Isha": "19:22"
    },
    {
     "Date": "09.06",
     "Fajr": "3:54",
     "Shuruq": "5:15",
     "Duhr": "11:37",
     "Asr": "15:11",
     "Maghrib": "18:03",
     "Isha": "19:20"
    },
    {
     "Date": "09.07",
     "Fajr": "3:55",
     "Shuruq": "5:16",
     "Duhr": "11:37",
     "Asr": "15:10",
     "Maghrib": "18:02",
     "Isha": "19:19"
    },
    {
     "Date": "09.08",
     "Fajr": "3:55",
     "Shuruq": "5:16",
     "Duhr": "11:36",
     "Asr": "15:10",
     "Maghrib": "18:01",
     "Isha": "19:17"
    },
    {
     "Date": "09.09",
     "Fajr": "3:56",
     "Shuruq": "5:17",
     "Duhr": "11:36",
     "Asr": "15:09",
     "Maghrib": "17:59",
     "Isha": "19:16"
    },
    {
     "Date": "09.10",
     "Fajr": "3:57",
     "Shuruq": "5:17",
     "Duhr": "11:36",
     "Asr": "15:08",
     "Maghrib": "17:58",
     "Isha": "19:14"
    },
    {
     "Date": "09.11",
     "Fajr": "3:58",
     "Shuruq": "5:18",
     "Duhr": "11:35",
     "Asr": "15:08",
     "Maghrib": "17:57",
     "Isha": "19:13"
    },
    {
     "Date": "09.12",
     "Fajr": "3:58",
     "Shuruq": "5:19",
     "Duhr": "11:35",
     "Asr": "15:07",
     "Maghrib": "17:55",
     "Isha": "19:12"
    },
    {
     "Date": "09.13",
     "Fajr": "3:59",
     "Shuruq": "5:19",
     "Duhr": "11:35",
     "Asr": "15:06",
     "Maghrib": "17:54",
     "Isha": "19:10"
    },
    {
     "Date": "09.14",
     "Fajr": "4:00",
     "Shuruq": "5:20",
     "Duhr": "11:34",
     "Asr": "15:05",
     "Maghrib": "17:53",
     "Isha": "19:09"
    },
    {
     "Date": "09.15",
     "Fajr": "4:01",
     "Shuruq": "5:21",
     "Duhr": "11:34",
     "Asr": "15:05",
     "Maghrib": "17:51",
     "Isha": "19:07"
    },
    {
     "Date": "09.16",
     "Fajr": "4:01",
     "Shuruq": "5:21",
     "Duhr": "11:34",
     "Asr": "15:04",
     "Maghrib": "17:50",
     "Isha": "19:06"
    },
    {
     "Date": "09.17",
     "Fajr": "4:02",
     "Shuruq": "5:22",
     "Duhr": "11:33",
     "Asr": "15:03",
     "Maghrib": "17:49",
     "Isha": "19:04"
    },
    {
     "Date": "09.18",
     "Fajr": "4:03",
     "Shuruq": "5:22",
     "Duhr": "11:33",
     "Asr": "15:02",
     "Maghrib": "17:47",
     "Isha": "19:03"
    },
    {
     "Date": "09.19",
     "Fajr": "4:04",
     "Shuruq": "5:23",
     "Duhr": "11:33",
     "Asr": "15:01",
     "Maghrib": "17:46",
     "Isha": "19:01"
    },
    {
     "Date": "09.20",
     "Fajr": "4:04",
     "Shuruq": "5:24",
     "Duhr": "11:32",
     "Asr": "15:01",
     "Maghrib": "17:45",
     "Isha": "19:00"
    },
    {
     "Date": "09.21",
     "Fajr": "4:05",
     "Shuruq": "5:24",
     "Duhr": "11:32",
     "Asr": "15:00",
     "Maghrib": "17:43",
     "Isha": "18:59"
    },
    {
     "Date": "09.22",
     "Fajr": "4:06",
     "Shuruq": "5:25",
     "Duhr": "11:31",
     "Asr": "14:59",
     "Maghrib": "17:42",
     "Isha": "18:57"
    },
    {
     "Date": "09.23",
     "Fajr": "4:06",
     "Shuruq": "5:26",
     "Duhr": "11:31",
     "Asr": "14:58",
     "Maghrib": "17:40",
     "Isha": "18:56"
    },
    {
     "Date": "09.24",
     "Fajr": "4:07",
     "Shuruq": "5:26",
     "Duhr": "11:31",
     "Asr": "14:57",
     "Maghrib": "17:39",
     "Isha": "18:54"
    },
    {
     "Date": "09.25",
     "Fajr": "4:08",
     "Shuruq": "5:27",
     "Duhr": "11:30",
     "Asr": "14:56",
     "Maghrib": "17:38",
     "Isha": "18:53"
    },
    {
     "Date": "09.26",
     "Fajr": "4:09",
     "Shuruq": "5:28",
     "Duhr": "11:30",
     "Asr": "14:56",
     "Maghrib": "17:36",
     "Isha": "18:52"
    },
    {
     "Date": "09.27",
     "Fajr": "4:09",
     "Shuruq": "5:28",
     "Duhr": "11:30",
     "Asr": "14:55",
     "Maghrib": "17:35",
     "Isha": "18:50"
    },
    {
     "Date": "09.28",
     "Fajr": "4:10",
     "Shuruq": "5:29",
     "Duhr": "11:29",
     "Asr": "14:54",
     "Maghrib": "17:34",
     "Isha": "18:49"
    },
    {
     "Date": "09.29",
     "Fajr": "4:11",
     "Shuruq": "5:30",
     "Duhr": "11:29",
     "Asr": "14:53",
     "Maghrib": "17:33",
     "Isha": "18:47"
    },
    {
     "Date": "09.30",
     "Fajr": "4:12",
     "Shuruq": "5:30",
     "Duhr": "11:29",
     "Asr": "14:52",
     "Maghrib": "17:32",
     "Isha": "18:46"
    },
    {
     "Date": "10.01",
     "Fajr": "4:12",
     "Shuruq": "5:31",
     "Duhr": "11:28",
     "Asr": "14:51",
     "Maghrib": "17:30",
     "Isha": "18:45"
    },
    {
     "Date": "10.02",
     "Fajr": "4:13",
     "Shuruq": "5:32",
     "Duhr": "11:28",
     "Asr": "14:50",
     "Maghrib": "17:29",
     "Isha": "18:43"
    },
    {
     "Date": "10.03",
     "Fajr": "4:13",
     "Shuruq": "5:32",
     "Duhr": "11:28",
     "Asr": "14:49",
     "Maghrib": "17:27",
     "Isha": "18:42"
    },
    {
     "Date": "10.04",
     "Fajr": "4:14",
     "Shuruq": "5:33",
     "Duhr": "11:27",
     "Asr": "14:49",
     "Maghrib": "17:26",
     "Isha": "18:41"
    },
    {
     "Date": "10.05",
     "Fajr": "4:15",
     "Shuruq": "5:34",
     "Duhr": "11:27",
     "Asr": "14:48",
     "Maghrib": "17:25",
     "Isha": "18:40"
    },
    {
     "Date": "10.06",
     "Fajr": "4:15",
     "Shuruq": "5:34",
     "Duhr": "11:27",
     "Asr": "14:47",
     "Maghrib": "17:23",
     "Isha": "18:38"
    },
    {
     "Date": "10.07",
     "Fajr": "4:16",
     "Shuruq": "5:35",
     "Duhr": "11:27",
     "Asr": "14:46",
     "Maghrib": "17:22",
     "Isha": "18:37"
    },
    {
     "Date": "10.08",
     "Fajr": "4:17",
     "Shuruq": "5:36",
     "Duhr": "11:26",
     "Asr": "14:45",
     "Maghrib": "17:21",
     "Isha": "18:36"
    },
    {
     "Date": "10.09",
     "Fajr": "4:17",
     "Shuruq": "5:36",
     "Duhr": "11:26",
     "Asr": "14:44",
     "Maghrib": "17:20",
     "Isha": "18:35"
    },
    {
     "Date": "10.10",
     "Fajr": "4:18",
     "Shuruq": "5:37",
     "Duhr": "11:26",
     "Asr": "14:43",
     "Maghrib": "17:18",
     "Isha": "18:33"
    },
    {
     "Date": "10.11",
     "Fajr": "4:19",
     "Shuruq": "5:38",
     "Duhr": "11:25",
     "Asr": "14:42",
     "Maghrib": "17:17",
     "Isha": "18:32"
    },
    {
     "Date": "10.12",
     "Fajr": "4:19",
     "Shuruq": "5:38",
     "Duhr": "11:25",
     "Asr": "14:42",
     "Maghrib": "17:16",
     "Isha": "18:31"
    },
    {
     "Date": "10.13",
     "Fajr": "4:20",
     "Shuruq": "5:39",
     "Duhr": "11:25",
     "Asr": "14:41",
     "Maghrib": "17:15",
     "Isha": "18:30"
    },
    {
     "Date": "10.14",
     "Fajr": "4:21",
     "Shuruq": "5:40",
     "Duhr": "11:25",
     "Asr": "14:40",
     "Maghrib": "17:14",
     "Isha": "18:29"
    },
    {
     "Date": "10.15",
     "Fajr": "4:21",
     "Shuruq": "5:40",
     "Duhr": "11:24",
     "Asr": "14:39",
     "Maghrib": "17:13",
     "Isha": "18:28"
    },
    {
     "Date": "10.16",
     "Fajr": "4:22",
     "Shuruq": "5:41",
     "Duhr": "11:24",
     "Asr": "14:38",
     "Maghrib": "17:11",
     "Isha": "18:26"
    },
    {
     "Date": "10.17",
     "Fajr": "4:23",
     "Shuruq": "5:42",
     "Duhr": "11:24",
     "Asr": "14:37",
     "Maghrib": "17:10",
     "Isha": "18:25"
    },
    {
     "Date": "10.18",
     "Fajr": "4:23",
     "Shuruq": "5:43",
     "Duhr": "11:24",
     "Asr": "14:37",
     "Maghrib": "17:09",
     "Isha": "18:24"
    },
    {
     "Date": "10.19",
     "Fajr": "4:24",
     "Shuruq": "5:43",
     "Duhr": "11:24",
     "Asr": "14:36",
     "Maghrib": "17:08",
     "Isha": "18:23"
    },
    {
     "Date": "10.20",
     "Fajr": "4:25",
     "Shuruq": "5:44",
     "Duhr": "11:23",
     "Asr": "14:35",
     "Maghrib": "17:07",
     "Isha": "18:22"
    },
    {
     "Date": "10.21",
     "Fajr": "4:25",
     "Shuruq": "5:45",
     "Duhr": "11:23",
     "Asr": "14:34",
     "Maghrib": "17:06",
     "Isha": "18:21"
    },
    {
     "Date": "10.22",
     "Fajr": "4:26",
     "Shuruq": "5:46",
     "Duhr": "11:23",
     "Asr": "14:33",
     "Maghrib": "17:05",
     "Isha": "18:20"
    },
    {
     "Date": "10.23",
     "Fajr": "4:27",
     "Shuruq": "5:46",
     "Duhr": "11:23",
     "Asr": "14:32",
     "Maghrib": "17:04",
     "Isha": "18:19"
    },
    {
     "Date": "10.24",
     "Fajr": "4:28",
     "Shuruq": "5:47",
     "Duhr": "11:23",
     "Asr": "14:32",
     "Maghrib": "17:03",
     "Isha": "18:18"
    },
    {
     "Date": "10.25",
     "Fajr": "4:28",
     "Shuruq": "5:48",
     "Duhr": "11:23",
     "Asr": "14:31",
     "Maghrib": "17:02",
     "Isha": "18:17"
    },
    {
     "Date": "10.26",
     "Fajr": "4:29",
     "Shuruq": "5:49",
     "Duhr": "11:23",
     "Asr": "14:30",
     "Maghrib": "17:01",
     "Isha": "18:16"
    },
    {
     "Date": "10.27",
     "Fajr": "4:30",
     "Shuruq": "5:49",
     "Duhr": "11:23",
     "Asr": "14:29",
     "Maghrib": "17:00",
     "Isha": "18:15"
    },
    {
     "Date": "10.28",
     "Fajr": "4:30",
     "Shuruq": "5:50",
     "Duhr": "11:22",
     "Asr": "14:29",
     "Maghrib": "16:59",
     "Isha": "18:15"
    },
    {
     "Date": "10.29",
     "Fajr": "4:31",
     "Shuruq": "5:51",
     "Duhr": "11:22",
     "Asr": "14:28",
     "Maghrib": "16:58",
     "Isha": "18:14"
    },
    {
     "Date": "10.30",
     "Fajr": "4:32",
     "Shuruq": "5:52",
     "Duhr": "11:22",
     "Asr": "14:27",
     "Maghrib": "16:57",
     "Isha": "18:13"
    },
    {
     "Date": "10.31",
     "Fajr": "4:32",
     "Shuruq": "5:53",
     "Duhr": "11:22",
     "Asr": "14:27",
     "Maghrib": "16:56",
     "Isha": "18:12"
    },
    {
     "Date": "11.01",
     "Fajr": "4:33",
     "Shuruq": "5:53",
     "Duhr": "11:22",
     "Asr": "14:26",
     "Maghrib": "16:55",
     "Isha": "18:11"
    },
    {
     "Date": "11.02",
     "Fajr": "4:34",
     "Shuruq": "5:54",
     "Duhr": "11:22",
     "Asr": "14:25",
     "Maghrib": "16:54",
     "Isha": "18:11"
    },
    {
     "Date": "11.03",
     "Fajr": "4:34",
     "Shuruq": "5:55",
     "Duhr": "11:22",
     "Asr": "14:25",
     "Maghrib": "16:53",
     "Isha": "18:10"
    },
    {
     "Date": "11.04",
     "Fajr": "4:35",
     "Shuruq": "5:56",
     "Duhr": "11:22",
     "Asr": "14:24",
     "Maghrib": "16:53",
     "Isha": "18:09"
    },
    {
     "Date": "11.05",
     "Fajr": "4:36",
     "Shuruq": "5:57",
     "Duhr": "11:22",
     "Asr": "14:23",
     "Maghrib": "16:52",
     "Isha": "18:09"
    },
    {
     "Date": "11.06",
     "Fajr": "4:37",
     "Shuruq": "5:57",
     "Duhr": "11:22",
     "Asr": "14:23",
     "Maghrib": "16:51",
     "Isha": "18:08"
    },
    {
     "Date": "11.07",
     "Fajr": "4:37",
     "Shuruq": "5:58",
     "Duhr": "11:22",
     "Asr": "14:22",
     "Maghrib": "16:50",
     "Isha": "18:07"
    },
    {
     "Date": "11.08",
     "Fajr": "4:38",
     "Shuruq": "5:59",
     "Duhr": "11:22",
     "Asr": "14:22",
     "Maghrib": "16:50",
     "Isha": "18:07"
    },
    {
     "Date": "11.09",
     "Fajr": "4:39",
     "Shuruq": "6:00",
     "Duhr": "11:22",
     "Asr": "14:21",
     "Maghrib": "16:49",
     "Isha": "18:06"
    },
    {
     "Date": "11.10",
     "Fajr": "4:39",
     "Shuruq": "6:01",
     "Duhr": "11:23",
     "Asr": "14:21",
     "Maghrib": "16:48",
     "Isha": "18:06"
    },
    {
     "Date": "11.11",
     "Fajr": "4:40",
     "Shuruq": "6:02",
     "Duhr": "11:23",
     "Asr": "14:20",
     "Maghrib": "16:48",
     "Isha": "18:05"
    },
    {
     "Date": "11.12",
     "Fajr": "4:41",
     "Shuruq": "6:02",
     "Duhr": "11:23",
     "Asr": "14:20",
     "Maghrib": "16:47",
     "Isha": "18:05"
    },
    {
     "Date": "11.13",
     "Fajr": "4:42",
     "Shuruq": "6:03",
     "Duhr": "11:23",
     "Asr": "14:19",
     "Maghrib": "16:47",
     "Isha": "18:04"
    },
    {
     "Date": "11.14",
     "Fajr": "4:42",
     "Shuruq": "6:04",
     "Duhr": "11:23",
     "Asr": "14:19",
     "Maghrib": "16:46",
     "Isha": "18:04"
    },
    {
     "Date": "11.15",
     "Fajr": "4:43",
     "Shuruq": "6:05",
     "Duhr": "11:23",
     "Asr": "14:19",
     "Maghrib": "16:45",
     "Isha": "18:03"
    },
    {
     "Date": "11.16",
     "Fajr": "4:44",
     "Shuruq": "6:06",
     "Duhr": "11:23",
     "Asr": "14:18",
     "Maghrib": "16:45",
     "Isha": "18:03"
    },
    {
     "Date": "11.17",
     "Fajr": "4:45",
     "Shuruq": "6:07",
     "Duhr": "11:23",
     "Asr": "14:18",
     "Maghrib": "16:45",
     "Isha": "18:03"
    },
    {
     "Date": "11.18",
     "Fajr": "4:45",
     "Shuruq": "6:07",
     "Duhr": "11:24",
     "Asr": "14:17",
     "Maghrib": "16:44",
     "Isha": "18:02"
    },
    {
     "Date": "11.19",
     "Fajr": "4:46",
     "Shuruq": "6:08",
     "Duhr": "11:24",
     "Asr": "14:17",
     "Maghrib": "16:44",
     "Isha": "18:02"
    },
    {
     "Date": "11.20",
     "Fajr": "4:47",
     "Shuruq": "6:09",
     "Duhr": "11:24",
     "Asr": "14:17",
     "Maghrib": "16:43",
     "Isha": "18:02"
    },
    {
     "Date": "11.21",
     "Fajr": "4:47",
     "Shuruq": "6:10",
     "Duhr": "11:24",
     "Asr": "14:17",
     "Maghrib": "16:43",
     "Isha": "18:01"
    },
    {
     "Date": "11.22",
     "Fajr": "4:48",
     "Shuruq": "6:11",
     "Duhr": "11:25",
     "Asr": "14:16",
     "Maghrib": "16:43",
     "Isha": "18:01"
    },
    {
     "Date": "11.23",
     "Fajr": "4:49",
     "Shuruq": "6:12",
     "Duhr": "11:25",
     "Asr": "14:16",
     "Maghrib": "16:42",
     "Isha": "18:01"
    },
    {
     "Date": "11.24",
     "Fajr": "4:50",
     "Shuruq": "6:12",
     "Duhr": "11:25",
     "Asr": "14:16",
     "Maghrib": "16:42",
     "Isha": "18:01"
    },
    {
     "Date": "11.25",
     "Fajr": "4:50",
     "Shuruq": "6:13",
     "Duhr": "11:26",
     "Asr": "14:16",
     "Maghrib": "16:42",
     "Isha": "18:01"
    },
    {
     "Date": "11.26",
     "Fajr": "4:51",
     "Shuruq": "6:14",
     "Duhr": "11:26",
     "Asr": "14:16",
     "Maghrib": "16:42",
     "Isha": "18:01"
    },
    {
     "Date": "11.27",
     "Fajr": "4:52",
     "Shuruq": "6:15",
     "Duhr": "11:26",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "11.28",
     "Fajr": "4:52",
     "Shuruq": "6:16",
     "Duhr": "11:27",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "11.29",
     "Fajr": "4:53",
     "Shuruq": "6:17",
     "Duhr": "11:27",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "11.30",
     "Fajr": "4:54",
     "Shuruq": "6:17",
     "Duhr": "11:27",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "12.01",
     "Fajr": "4:55",
     "Shuruq": "6:18",
     "Duhr": "11:28",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "12.02",
     "Fajr": "4:55",
     "Shuruq": "6:19",
     "Duhr": "11:28",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "12.03",
     "Fajr": "4:56",
     "Shuruq": "6:20",
     "Duhr": "11:28",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "12.04",
     "Fajr": "4:57",
     "Shuruq": "6:20",
     "Duhr": "11:29",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "12.05",
     "Fajr": "4:57",
     "Shuruq": "6:21",
     "Duhr": "11:29",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "12.06",
     "Fajr": "4:58",
     "Shuruq": "6:22",
     "Duhr": "11:30",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "12.07",
     "Fajr": "4:59",
     "Shuruq": "6:23",
     "Duhr": "11:30",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:01"
    },
    {
     "Date": "12.08",
     "Fajr": "4:59",
     "Shuruq": "6:23",
     "Duhr": "11:30",
     "Asr": "14:16",
     "Maghrib": "16:41",
     "Isha": "18:02"
    },
    {
     "Date": "12.09",
     "Fajr": "5:00",
     "Shuruq": "6:24",
     "Duhr": "11:31",
     "Asr": "14:16",
     "Maghrib": "16:42",
     "Isha": "18:02"
    },
    {
     "Date": "12.10",
     "Fajr": "5:01",
     "Shuruq": "6:25",
     "Duhr": "11:31",
     "Asr": "14:17",
     "Maghrib": "16:42",
     "Isha": "18:02"
    },
    {
     "Date": "12.11",
     "Fajr": "5:01",
     "Shuruq": "6:26",
     "Duhr": "11:32",
     "Asr": "14:17",
     "Maghrib": "16:42",
     "Isha": "18:02"
    },
    {
     "Date": "12.12",
     "Fajr": "5:02",
     "Shuruq": "6:26",
     "Duhr": "11:32",
     "Asr": "14:17",
     "Maghrib": "16:42",
     "Isha": "18:03"
    },
    {
     "Date": "12.13",
     "Fajr": "5:03",
     "Shuruq": "6:27",
     "Duhr": "11:33",
     "Asr": "14:17",
     "Maghrib": "16:43",
     "Isha": "18:03"
    },
    {
     "Date": "12.14",
     "Fajr": "5:03",
     "Shuruq": "6:28",
     "Duhr": "11:33",
     "Asr": "14:18",
     "Maghrib": "16:43",
     "Isha": "18:03"
    },
    {
     "Date": "12.15",
     "Fajr": "5:04",
     "Shuruq": "6:28",
     "Duhr": "11:34",
     "Asr": "14:18",
     "Maghrib": "16:43",
     "Isha": "18:04"
    },
    {
     "Date": "12.16",
     "Fajr": "5:04",
     "Shuruq": "6:29",
     "Duhr": "11:34",
     "Asr": "14:18",
     "Maghrib": "16:44",
     "Isha": "18:04"
    },
    {
     "Date": "12.17",
     "Fajr": "5:05",
     "Shuruq": "6:29",
     "Duhr": "11:35",
     "Asr": "14:19",
     "Maghrib": "16:44",
     "Isha": "18:04"
    },
    {
     "Date": "12.18",
     "Fajr": "5:05",
     "Shuruq": "6:30",
     "Duhr": "11:35",
     "Asr": "14:19",
     "Maghrib": "16:44",
     "Isha": "18:05"
    },
    {
     "Date": "12.19",
     "Fajr": "5:06",
     "Shuruq": "6:30",
     "Duhr": "11:36",
     "Asr": "14:19",
     "Maghrib": "16:45",
     "Isha": "18:05"
    },
    {
     "Date": "12.20",
     "Fajr": "5:06",
     "Shuruq": "6:31",
     "Duhr": "11:36",
     "Asr": "14:20",
     "Maghrib": "16:45",
     "Isha": "18:06"
    },
    {
     "Date": "12.21",
     "Fajr": "5:07",
     "Shuruq": "6:32",
     "Duhr": "11:37",
     "Asr": "14:20",
     "Maghrib": "16:46",
     "Isha": "18:06"
    },
    {
     "Date": "12.22",
     "Fajr": "5:07",
     "Shuruq": "6:32",
     "Duhr": "11:37",
     "Asr": "14:21",
     "Maghrib": "16:46",
     "Isha": "18:07"
    },
    {
     "Date": "12.23",
     "Fajr": "5:08",
     "Shuruq": "6:32",
     "Duhr": "11:38",
     "Asr": "14:21",
     "Maghrib": "16:47",
     "Isha": "18:07"
    },
    {
     "Date": "12.24",
     "Fajr": "5:08",
     "Shuruq": "6:33",
     "Duhr": "11:38",
     "Asr": "14:22",
     "Maghrib": "16:47",
     "Isha": "18:08"
    },
    {
     "Date": "12.25",
     "Fajr": "5:09",
     "Shuruq": "6:33",
     "Duhr": "11:39",
     "Asr": "14:23",
     "Maghrib": "16:48",
     "Isha": "18:08"
    },
    {
     "Date": "12.26",
     "Fajr": "5:09",
     "Shuruq": "6:34",
     "Duhr": "11:39",
     "Asr": "14:24",
     "Maghrib": "16:48",
     "Isha": "18:09"
    },
    {
     "Date": "12.27",
     "Fajr": "5:10",
     "Shuruq": "6:34",
     "Duhr": "11:40",
     "Asr": "14:24",
     "Maghrib": "16:49",
     "Isha": "18:10"
    },
    {
     "Date": "12.28",
     "Fajr": "5:10",
     "Shuruq": "6:34",
     "Duhr": "11:40",
     "Asr": "14:25",
     "Maghrib": "16:50",
     "Isha": "18:10"
    },
    {
     "Date": "12.29",
     "Fajr": "5:10",
     "Shuruq": "6:35",
     "Duhr": "11:41",
     "Asr": "14:25",
     "Maghrib": "16:50",
     "Isha": "18:11"
    },
    {
     "Date": "12.30",
     "Fajr": "5:11",
     "Shuruq": "6:35",
     "Duhr": "11:41",
     "Asr": "14:26",
     "Maghrib": "16:51",
     "Isha": "18:11"
    },
    {
     "Date": "12.31",
     "Fajr": "5:11",
     "Shuruq": "6:35",
     "Duhr": "11:42",
     "Asr": "14:27",
     "Maghrib": "16:52",
     "Isha": "18:12"
    }
   ]''';
