import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';

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
  const BeforeClockWidget({Key? key, required this.time}) : super(key: key);
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      return Text(
        DateFormat('kk:mm:ss')
            .format(DateTime.now().subtract(Duration(hours: time.hour, minutes: time.minute))),
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 32,
        ),
      );
    });
  }
}

class AfterClockWidget extends StatelessWidget {
  const AfterClockWidget({Key? key, required this.time}) : super(key: key);
  final DateTime time;

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
      return Text(
        printDuration(time.difference(DateTime.now())),
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 32,
        ),
      );
    });
  }
}
