import 'package:flutter/material.dart';
import 'card_widget.dart';

class PrayerWidget extends StatefulWidget {
  const PrayerWidget({Key? key, required this.label, required this.time}) : super(key: key);

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
