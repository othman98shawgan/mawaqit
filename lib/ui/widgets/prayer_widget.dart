import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/prayer_alarm_service.dart';
import '../../services/prayer_methods.dart';
import 'alarm_dialog.dart';
import 'card_widget.dart';

class PrayerWidget extends StatefulWidget {
  const PrayerWidget({
    super.key,
    required this.label,
    required this.time,
    this.height = 0,
    this.rawPrayerTime,
    this.showAlarm = true,
  });

  final String label;
  final String time;
  final double height;
  final DateTime? rawPrayerTime;
  final bool showAlarm;

  @override
  State<PrayerWidget> createState() => PrayerState();
}

class PrayerState extends State<PrayerWidget> {
  bool _hasAlarm = false;

  @override
  void initState() {
    super.initState();
    _checkAlarmStatus();
  }

  @override
  void didUpdateWidget(covariant PrayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label || oldWidget.time != widget.time) {
      _checkAlarmStatus();
    }
  }

  Future<void> _checkAlarmStatus() async {
    if (kIsWeb || !Platform.isAndroid) return;
    final settings = await PrayerAlarmService.loadAlarmSettings(widget.label);
    if (mounted) {
      setState(() {
        _hasAlarm = settings.isEnabled;
      });
    }
  }

  DateTime _resolvePrayerDateTime() {
    if (widget.rawPrayerTime != null) {
      return widget.rawPrayerTime!;
    }
    final now = DateTime.now();
    try {
      final parts = widget.time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (_) {
      return now;
    }
  }

  void _openAlarmDialog() {
    if (kIsWeb || !Platform.isAndroid) return;
    showDialog(
      context: context,
      builder: (context) => AlarmDialog(
        prayerName: widget.label,
        prayerTime: _resolvePrayerDateTime(),
        onSaved: _checkAlarmStatus,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var labelStyle = const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 28,
      color: Colors.white,
    );
    var timeStyle = GoogleFonts.roboto(
      fontWeight: FontWeight.w300,
      fontSize: 28,
      color: Colors.white,
    );

    return MyCard(
      height: widget.height,
      widget: ListTile(
        textColor: Colors.white,
        iconColor: Colors.white,
        onTap: (widget.showAlarm && !kIsWeb && Platform.isAndroid) ? _openAlarmDialog : null,
        leading: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            getPrayerTranslation(widget.label, context),
            style: labelStyle,
            textAlign: TextAlign.center,
          ),
        ),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showAlarm && !kIsWeb && Platform.isAndroid)
                IconButton(
                  tooltip: _hasAlarm ? 'Alarm active' : 'Set alarm',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _hasAlarm ? Icons.alarm_on : Icons.alarm_add_outlined,
                    color: _hasAlarm ? Colors.amberAccent : Colors.white54,
                    size: 24,
                  ),
                  onPressed: _openAlarmDialog,
                ),
              if (widget.showAlarm && !kIsWeb && Platform.isAndroid) const SizedBox(width: 8),
              Text(
                widget.time,
                style: timeStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
