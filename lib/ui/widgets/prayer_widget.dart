import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prayer_methods.dart';
import 'card_widget.dart';

class PrayerWidget extends StatefulWidget {
  const PrayerWidget({Key? key, required this.label, required this.time, this.height = 0})
      : super(key: key);

  final String label;
  final String time;
  final double height;

  @override
  State<PrayerWidget> createState() => PrayerState();
}

class PrayerState extends State<PrayerWidget> {
  @override
  Widget build(BuildContext context) {
    var labelStyle = const TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 28,
    );
    var timeStyle = GoogleFonts.roboto(
      fontWeight: FontWeight.w300,
      fontSize: 28,
    );

    return MyCard(
      height: widget.height,
      widget: ListTile(
        leading: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            getPrayerTranslation(widget.label, context),
            style: labelStyle,
            textAlign: TextAlign.center,
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.all(18.0),
          child: Text(""),
        ),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.time,
            style: timeStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
