import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/prayer_alarm.dart';
import '../../services/notifications_service.dart';
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
  String _alertMode = PrayerAlarmSettings.modeNotification;

  bool get _supportsAlerts =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isWindows);

  bool get _canShowAlert => widget.showAlarm && _supportsAlerts;

  @override
  void initState() {
    super.initState();
    PrayerAlarmService.alarmSettingsVersion.addListener(_onAlarmSettingsChanged);
    _checkAlarmStatus();
  }

  @override
  void dispose() {
    PrayerAlarmService.alarmSettingsVersion.removeListener(_onAlarmSettingsChanged);
    super.dispose();
  }

  void _onAlarmSettingsChanged() {
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
    if (!_supportsAlerts) return;
    final settings = await PrayerAlarmService.loadAlarmSettings(widget.label);
    if (mounted) {
      setState(() {
        _alertMode = settings.alertMode;
      });
    }
  }

  void _openAlarmDialog() {
    if (!_supportsAlerts) return;
    showAlarmBottomSheet(
      context,
      initialPrayerName: widget.label,
      onSaved: _checkAlarmStatus,
    );
  }

  bool _isAlertEffectivelyActive(bool masterNotificationsEnabled) {
    if (!kIsWeb && Platform.isAndroid && _alertMode == PrayerAlarmSettings.modeAlarm) {
      return true;
    }
    return masterNotificationsEnabled && _alertMode != PrayerAlarmSettings.modeOff;
  }

  IconData _resolveAlertIcon(bool masterNotificationsEnabled) {
    if (!kIsWeb && Platform.isAndroid && _alertMode == PrayerAlarmSettings.modeAlarm) {
      return Icons.notifications_active;
    }
    if (!masterNotificationsEnabled || _alertMode == PrayerAlarmSettings.modeOff) {
      return Icons.notifications_off_outlined;
    }
    return Icons.notifications_outlined;
  }

  Color _resolveAlertColor(bool masterNotificationsEnabled) {
    return _isAlertEffectivelyActive(masterNotificationsEnabled) ? Colors.white : Colors.white38;
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

    bool masterEnabled = true;
    if (_canShowAlert) {
      try {
        masterEnabled = Provider.of<NotificationsStatusNotifier>(context).getNotificationsStatus();
      } catch (_) {
        masterEnabled = true;
      }
    }

    return MyCard(
      height: widget.height,
      widget: ListTile(
        contentPadding: EdgeInsetsDirectional.only(
          start: 16,
          end: _canShowAlert ? 10 : 16,
        ),
        textColor: Colors.white,
        iconColor: Colors.white,
        onTap: _canShowAlert ? _openAlarmDialog : null,
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
              Text(
                widget.time,
                style: timeStyle,
                textAlign: TextAlign.center,
              ),
              if (_canShowAlert) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: _isAlertEffectivelyActive(masterEnabled)
                      ? 'Notifications on'
                      : 'Notifications off',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    _resolveAlertIcon(masterEnabled),
                    color: _resolveAlertColor(masterEnabled),
                    size: 24,
                  ),
                  onPressed: _openAlarmDialog,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
