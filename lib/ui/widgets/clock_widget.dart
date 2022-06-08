import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';

import '../../models/prayer.dart';

class ClockWidget extends StatelessWidget {
  const ClockWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
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

class BeforeClockWidget extends StatelessWidget {
  const BeforeClockWidget({Key? key, required this.prayer}) : super(key: key);
  final Prayer prayer;

  String printDuration(Duration duration) {
    return "${addZero(duration.inHours.toString())}:"
        "${addZero(duration.inMinutes.remainder(60).toString())}:"
        "${addZero(duration.inSeconds.remainder(60).toString())}";
  }

  String addZero(String time) {
    if (time.length == 2) return time;
    return '0$time';
  }

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      var now = DateTime.now();
      return Row(
        children: [
          Text("Time since ${prayer.label}:   ",
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 18,
              )),
          Text(
            printDuration(DateTime.now().difference(prayer.time)),
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 32,
            ),
          )
        ],
      );
    });
  }
}

class AfterClockWidget extends StatelessWidget {
  const AfterClockWidget({Key? key, required this.prayer}) : super(key: key);
  final Prayer prayer;

  String printDuration(Duration duration) {
    return "${addZero(duration.inHours.toString())}:"
        "${addZero(duration.inMinutes.remainder(60).toString())}:"
        "${addZero(duration.inSeconds.remainder(60).toString())}";
  }

  String addZero(String time) {
    if (time.length == 2) return time;
    return '0$time';
  }

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      return Row(
        children: [
          Text("Time until ${prayer.label}:   ",
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 18,
              )),
          Text(
            printDuration(prayer.time.difference(DateTime.now())),
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 32,
            ),
          )
        ],
      );
    });
  }
}
