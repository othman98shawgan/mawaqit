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

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      var now = DateTime.now();
      return Text(
        DateFormat('kk:mm:ss').format(
            time.subtract(Duration(hours: now.hour, minutes: now.minute, seconds: now.second))),
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 32,
        ),
      );
    });
  }
}
