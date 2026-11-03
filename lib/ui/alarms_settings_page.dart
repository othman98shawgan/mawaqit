import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alfajr/l10n/app_localizations.dart';

import '../models/prayer_alarm.dart';
import '../resources/colors.dart';
import '../services/prayer_alarm_service.dart';
import '../services/prayer_methods.dart';
import '../services/store_manager.dart';
import 'widgets/alarm_dialog.dart';

class AlarmsSettingsPage extends StatefulWidget {
  const AlarmsSettingsPage({super.key});

  @override
  State<AlarmsSettingsPage> createState() => _AlarmsSettingsPageState();
}

class _AlarmsSettingsPageState extends State<AlarmsSettingsPage> with WidgetsBindingObserver {
  Map<String, PrayerAlarmSettings> _alarms = {};
  bool _isLoading = true;
  bool _batteryOptIgnored = true;
  bool _fullScreenIntentGranted = true;
  bool _isDevMode = false;
  String _testSound = 'alaqsa';
  int _testDelay = 5;
  bool _isTestingAlarm = false;

  final List<String> _prayers = ['Fajr', 'Shuruq', 'Duhr', 'Asr', 'Maghrib', 'Isha'];
  final List<String> _soundOptions = [
    'alaqsa',
    'makkah',
    'madina',
    'abdulbasit',
    'minshawi',
    'hussary',
    'nafees',
    'system',
    'silent',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAll();
    }
  }

  Future<void> _loadAll() async {
    final loaded = await PrayerAlarmService.loadAllAlarmSettings();
    final ignored = await PrayerAlarmService.isBatteryOptimizationIgnored();
    final fullScreen = await PrayerAlarmService.canUseFullScreenIntent();
    final dev = await StorageManager.readData('isDevMode');
    final isDev = dev is bool && dev;
    if (mounted) {
      setState(() {
        _alarms = loaded;
        _batteryOptIgnored = ignored;
        _fullScreenIntentGranted = fullScreen;
        _isDevMode = isDev;
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
      case 'system':
        return l10n.soundSystem;
      case 'silent':
        return l10n.soundSilent;
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
        prayerTime: DateTime.now(),
        onSaved: _loadAll,
      ),
    );
  }

  Future<void> _triggerTestAlarm() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isTestingAlarm = true);

    await PrayerAlarmService.scheduleTestAlarm(
      soundType: _testSound,
      delaySeconds: _testDelay,
      title: l10n.testAlarmTitle,
      body: _getSoundTitle(_testSound, l10n),
      dismissLabel: l10n.alarmDismiss,
      snoozeLabel: l10n.alarmSnooze,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.alarmScheduledInSeconds(_testDelay)),
          backgroundColor: prayerColor,
          duration: const Duration(seconds: 4),
        ),
      );
      Future.delayed(Duration(seconds: _testDelay + 1), () {
        if (mounted) {
          setState(() => _isTestingAlarm = false);
        }
      });
    }
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
                if (!kIsWeb && Platform.isAndroid && !_fullScreenIntentGranted) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade400),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.screen_lock_portrait, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.fullScreenIntentTitle,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.fullScreenIntentDesc,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            icon: const Icon(Icons.settings, size: 16),
                            label: Text(l10n.fullScreenIntentAction),
                            onPressed: () async {
                              await PrayerAlarmService.openFullScreenIntentSettings();
                              Future.delayed(const Duration(seconds: 1), _loadAll);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

                // Test Custom Alarm Section (Only visible when developer options are enabled)
                if (_isDevMode) ...[
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.play_circle_fill, color: prayerColor, size: 26),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.testAlarmTitle,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.testAlarmDesc,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: _testSound,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: l10n.alarmSound,
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  items: _soundOptions.map((s) {
                                    return DropdownMenuItem<String>(
                                      value: s,
                                      child: Text(_getSoundTitle(s, l10n), style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _testSound = val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<int>(
                                  value: _testDelay,
                                  decoration: InputDecoration(
                                    labelText: l10n.alarmDelay,
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 5, child: Text("5s")),
                                    DropdownMenuItem(value: 10, child: Text("10s")),
                                    DropdownMenuItem(value: 15, child: Text("15s")),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _testDelay = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: prayerColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _isTestingAlarm ? null : _triggerTestAlarm,
                              icon: const Icon(Icons.alarm, size: 20),
                              label: Text(
                                _isTestingAlarm ? "Scheduling..." : l10n.triggerAlarmInSeconds(_testDelay),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  l10n.testAlarmLockHint,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Configured Prayers Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Text(
                    l10n.configuredPrayerAlarms,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),

                // Prayer List
                ..._prayers.map((prayer) {
                  final settings = _alarms[prayer] ?? PrayerAlarmSettings(prayerName: prayer);
                  final prayerTitle = getPrayerTranslation(prayer, context);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
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
