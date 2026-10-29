import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alfajr/l10n/app_localizations.dart';

import '../models/prayer_alarm.dart';
import '../resources/colors.dart';
import '../services/prayer_alarm_service.dart';
import '../services/prayer_methods.dart';
import 'widgets/alarm_dialog.dart';

class AlarmsSettingsPage extends StatefulWidget {
  const AlarmsSettingsPage({super.key});

  @override
  State<AlarmsSettingsPage> createState() => _AlarmsSettingsPageState();
}

class _AlarmsSettingsPageState extends State<AlarmsSettingsPage> {
  Map<String, PrayerAlarmSettings> _alarms = {};
  bool _isLoading = true;
  bool _batteryOptIgnored = true;

  final List<String> _prayers = ['Fajr', 'Shuruq', 'Duhr', 'Asr', 'Maghrib', 'Isha'];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final loaded = await PrayerAlarmService.loadAllAlarmSettings();
    final ignored = await PrayerAlarmService.isBatteryOptimizationIgnored();
    if (mounted) {
      setState(() {
        _alarms = loaded;
        _batteryOptIgnored = ignored;
        _isLoading = false;
      });
    }
  }

  String _getSoundTitle(String soundKey, AppLocalizations l10n) {
    switch (soundKey) {
      case 'alaqsa':
        return l10n.soundAlaqsa;
      case 'makkah':
        return l10n.soundMakkah;
      case 'madina':
        return l10n.soundMadina;
      case 'abdulbasit':
        return l10n.soundAbdulbasit;
      case 'minshawi':
        return l10n.soundMinshawi;
      case 'hussary':
        return l10n.soundHussary;
      case 'nafees':
        return l10n.soundNafees;
      case 'chime':
        return l10n.soundChime;
      case 'system':
      default:
        return l10n.soundSystem;
    }
  }

  String _getSubtitle(PrayerAlarmSettings settings, AppLocalizations l10n) {
    if (!settings.isEnabled) {
      return l10n.alarmSnoozeOff;
    }
    final offsetText = settings.offsetMinutes == 0
        ? l10n.alarmOffsetExact
        : l10n.alarmOffsetBefore(settings.offsetMinutes.abs());
    final soundText = _getSoundTitle(settings.soundType, l10n);
    return '$offsetText • $soundText';
  }

  void _openAlarmDialog(String prayerName) {
    showDialog(
      context: context,
      builder: (context) => AlarmDialog(
        prayerName: prayerName,
        prayerTime: DateTime.now(), // Fallback base time
        onSaved: _loadAll,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alarmSection),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!kIsWeb && Platform.isAndroid && !_batteryOptIgnored) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade700),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.battery_alert, color: Colors.amber.shade800),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.batteryOptimizationTitle,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.batteryOptimizationDesc,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () async {
                              final granted = await PrayerAlarmService.requestIgnoreBatteryOptimization();
                              if (mounted) {
                                setState(() {
                                  _batteryOptIgnored = granted;
                                });
                              }
                            },
                            icon: const Icon(Icons.check, size: 18),
                            label: Text(l10n.disableBatteryOptimization, style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                ..._prayers.map((prayer) {
                  final settings = _alarms[prayer] ?? PrayerAlarmSettings(prayerName: prayer);
                  final prayerTitle = getPrayerTranslation(prayer, context);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(
                        settings.isEnabled ? Icons.alarm_on : Icons.alarm_off,
                        color: settings.isEnabled ? prayerColor : Colors.grey,
                        size: 28,
                      ),
                      title: Text(
                        prayerTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_getSubtitle(settings, l10n)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openAlarmDialog(prayer),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
