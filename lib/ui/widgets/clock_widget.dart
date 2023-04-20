import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/prayer.dart';
import '../../models/prayers.dart';
import '../../services/prayer_methods.dart';

class ClockWidget extends StatelessWidget {
  const ClockWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      return Text(
        DateFormat('HH:mm:ss').format(DateTime.now()),
        style: const TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 48,
        ),
      );
    });
  }
}

class PrayerClockWidget extends StatefulWidget {
  const PrayerClockWidget(
      {Key? key, required this.prayersToday, required this.summerTime, required this.prayerList})
      : super(key: key);

  final PrayersModel prayersToday;
  final bool summerTime;
  final List prayerList;

  @override
  State<PrayerClockWidget> createState() => _PrayerClockState();
}

class _PrayerClockState extends State<PrayerClockWidget> {
  late Prayer next;
  late Prayer prev;

  void updatePrayers() {
    next = getNextPrayer(DateTime.now(), widget.prayersToday, widget.summerTime, widget.prayerList);
    prev = getPrevPrayer(DateTime.now(), widget.prayersToday, widget.summerTime, widget.prayerList);
  }

  String printDuration(Duration duration) {
    if (duration.isNegative) {
      updatePrayers();
    }
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
    updatePrayers();
    var prayerTextStyle = const TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 18,
    );

    var prayerTimeStyle = const TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 28,
    );

    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      var nextText = printDuration(next.time.difference(DateTime.now()));
      var prevText = printDuration(DateTime.now().difference(prev.time));
      return Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 40.0, right: 40.0),
            visualDensity: const VisualDensity(vertical: -4),
            leading: Text(AppLocalizations.of(context)!.timeUntil(getPrayerTranslation(next.label, context)),
                style: prayerTextStyle),
            trailing: Text(nextText, style: prayerTimeStyle),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 40.0, right: 40.0),
            visualDensity: const VisualDensity(vertical: -4),
            leading: Text(AppLocalizations.of(context)!.timeSince(getPrayerTranslation(prev.label, context)),
                style: prayerTextStyle),
            trailing: Text(prevText, style: prayerTimeStyle),
          )
        ],
      );
    });
  }
}
