import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/prayer.dart';
import '../../models/prayers.dart';
import '../../services/locale_service.dart';
import '../../services/prayer_methods.dart';

class ClockWidget extends StatelessWidget {
  const ClockWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            DateFormat('HH:mm:ss').format(DateTime.now()),
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w300,
              fontSize: 48,
            ),
          ));
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
    var width = MediaQuery.of(context).size.width;
    var locale = Provider.of<LocaleNotifier>(context, listen: false).locale.toString();
    var prayerTextAlingment = locale == 'ar' ? Alignment.centerRight : Alignment.centerLeft;
    var prayerTextWidth = locale == 'ar' ? width * 0.45 : width * 0.4;

    updatePrayers();
    var prayerTextStyle = const TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 18,
    );

    var prayerTimeStyle = GoogleFonts.roboto(
      fontWeight: FontWeight.w300,
      fontSize: 24,
    );

    return TimerBuilder.periodic(const Duration(seconds: 1), builder: (context) {
      var nextText = printDuration(next.time.difference(DateTime.now()));
      var prevText = printDuration(DateTime.now().difference(prev.time));

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: width * 0.1,
              ),
              SizedBox(
                width: prayerTextWidth,
                child: FittedBox(
                  alignment: prayerTextAlingment,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!
                        .timeUntil(getPrayerTranslation(next.label, context)),
                    style: prayerTextStyle,
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.025,
              ),
              SizedBox(
                width: width * 0.3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(nextText, style: prayerTimeStyle, textAlign: TextAlign.center),
                ),
              ),
              SizedBox(
                width: width * 0.1,
              ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: width * 0.1,
              ),
              SizedBox(
                width: prayerTextWidth,
                child: FittedBox(
                  alignment: prayerTextAlingment,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!
                        .timeSince(getPrayerTranslation(prev.label, context)),
                    style: prayerTextStyle,
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.025,
              ),
              SizedBox(
                width: width * 0.3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(prevText, style: prayerTimeStyle, textAlign: TextAlign.center),
                ),
              ),
              SizedBox(
                width: width * 0.1,
              ),
            ],
          ),
        ],
      );
    });
  }
}
