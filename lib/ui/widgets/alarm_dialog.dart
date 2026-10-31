import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alfajr/l10n/app_localizations.dart';

import '../../models/prayer_alarm.dart';
import '../../resources/colors.dart';
import '../../services/daylight_time_service.dart';
import '../../services/locale_service.dart';
import '../../services/prayer_alarm_service.dart';
import '../../services/prayer_methods.dart';

class AlarmDialog extends StatefulWidget {
  final String prayerName;
  final DateTime prayerTime;
  final VoidCallback? onSaved;

  const AlarmDialog({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    this.onSaved,
  });

  @override
  State<AlarmDialog> createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> with WidgetsBindingObserver {
  bool _isLoading = true;
  late PrayerAlarmSettings _settings;
  bool _batteryOptimizationIgnored = true;
  bool _fullScreenIntentGranted = true;

  final List<String> _soundOptions = [
    'alaqsa',
    'makkah',
    'madina',
    'abdulbasit',
    'minshawi',
    'hussary',
    'nafees',
    'system',
    'silent'
  ];
  final List<int> _snoozeOptions = [0, 5, 10, 15];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSettings();
    }
  }

  Future<void> _loadSettings() async {
    final loaded = await PrayerAlarmService.loadAlarmSettings(widget.prayerName);
    final ignored = await PrayerAlarmService.isBatteryOptimizationIgnored();
    final fullScreen = await PrayerAlarmService.canUseFullScreenIntent();
    if (mounted) {
      setState(() {
        _settings = loaded;
        _batteryOptimizationIgnored = ignored;
        _fullScreenIntentGranted = fullScreen;
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

  String _getOffsetTitle(int offset, AppLocalizations l10n) {
    if (offset == 0) {
      return l10n.alarmOffsetExact;
    }
    return l10n.alarmOffsetBefore(offset.abs());
  }

  String _getSnoozeTitle(int minutes, AppLocalizations l10n) {
    if (minutes <= 0) {
      return l10n.alarmSnoozeOff;
    }
    return l10n.alarmSnoozeMinutes(minutes);
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context)!;
    final dstNotifier = Provider.of<DaylightSavingNotifier>(context, listen: false);
    final diff = Provider.of<LocaleNotifier>(context, listen: false).timeDiff;
    final localizedTitles = getLocalizedPrayerAlarmTitles(context);
    await PrayerAlarmService.saveAlarmSettings(_settings);

    if (!kIsWeb && Platform.isAndroid) {
      if (!_settings.isEnabled) {
        await PrayerAlarmService.cancelAlarm(widget.prayerName);
      } else {
        // If enabling alarm, proactively guide the user through permissions
        if (!_batteryOptimizationIgnored) {
          final granted = await PrayerAlarmService.requestIgnoreBatteryOptimization();
          _batteryOptimizationIgnored = granted;
        }

        if (!_fullScreenIntentGranted && mounted) {
          final grantTapped = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.screen_lock_portrait, color: prayerColor, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.fullScreenIntentTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Text(
                l10n.fullScreenIntentDesc,
                style: const TextStyle(fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    l10n.cancelString,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: prayerColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  icon: const Icon(Icons.settings, size: 16),
                  label: Text(l10n.fullScreenIntentAction),
                ),
              ],
            ),
          );

          if (grantTapped == true) {
            await PrayerAlarmService.openFullScreenIntentSettings();
          }
        }
      }
      final alarmSettingsMap = await PrayerAlarmService.loadAllAlarmSettings();
      if (!mounted) return;
      alarmSettingsMap[widget.prayerName] = _settings;
      final offsets = alarmSettingsMap.map((k, v) => MapEntry(k, v.offsetMinutes));
      final localizedBodies = getLocalizedPrayerAlarmMessages(context, offsets);

      await PrayerAlarmService.scheduleUpcomingAlarms(
        summerTime: dstNotifier.getSummerTime(),
        timeDiff: diff,
        localizedTitles: localizedTitles,
        localizedBodies: localizedBodies,
      );
    }

    widget.onSaved?.call();
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prayerTitle = getPrayerTranslation(widget.prayerName, context);

    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.alarm, color: prayerColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.prayerAlarmTitle(prayerTitle),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enable Alarm Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.enableAlarm,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              value: _settings.isEnabled,
              onChanged: (val) {
                setState(() {
                  _settings = _settings.copyWith(isEnabled: val);
                });
              },
            ),
            const Divider(),

            if (_settings.isEnabled) ...[
              // Alarm Time / Offset
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.alarmOffset,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    _getOffsetTitle(_settings.offsetMinutes, l10n),
                    style: TextStyle(
                      color: prayerColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Slider(
                  value: (_settings.offsetMinutes.abs().toDouble()).clamp(0.0, 60.0),
                  min: 0,
                  max: 60,
                  divisions: 12,
                  label: '${_settings.offsetMinutes.abs()}m',
                  onChanged: (val) {
                    setState(() {
                      _settings = _settings.copyWith(
                        offsetMinutes: val == 0 ? 0 : -val.round(),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Sound Selection
              DropdownButtonFormField<String>(
                value: _soundOptions.contains(_settings.soundType) ? _settings.soundType : 'alaqsa',
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.alarmSound,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _soundOptions.map((sound) {
                  return DropdownMenuItem<String>(
                    value: sound,
                    child: Text(_getSoundTitle(sound, l10n)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _settings = _settings.copyWith(soundType: val);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Snooze Duration
              DropdownButtonFormField<int>(
                value: _snoozeOptions.contains(_settings.snoozeMinutes) ? _settings.snoozeMinutes : 10,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.alarmSnoozeDuration,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _snoozeOptions.map((minutes) {
                  return DropdownMenuItem<int>(
                    value: minutes,
                    child: Text(_getSnoozeTitle(minutes, l10n)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _settings = _settings.copyWith(snoozeMinutes: val);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              if (!kIsWeb && Platform.isAndroid && !_fullScreenIntentGranted) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade400, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.screen_lock_portrait, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.fullScreenIntentTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.fullScreenIntentDesc,
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () async {
                            await PrayerAlarmService.openFullScreenIntentSettings();
                            Future.delayed(const Duration(seconds: 1), _loadSettings);
                          },
                          icon: const Icon(Icons.settings, size: 16),
                          label: Text(l10n.fullScreenIntentAction, style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Battery Optimization warning banner (Android only)
              if (!kIsWeb && Platform.isAndroid && !_batteryOptimizationIgnored) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.battery_alert, color: Colors.amber.shade800, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.batteryOptimizationTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.batteryOptimizationDesc,
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () async {
                            final granted = await PrayerAlarmService.requestIgnoreBatteryOptimization();
                            if (mounted) {
                              setState(() {
                                _batteryOptimizationIgnored = granted;
                              });
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: Text(l10n.disableBatteryOptimization, style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel,
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: prayerColor),
          onPressed: _saveSettings,
          child: Text(
            MaterialLocalizations.of(context).okButtonLabel,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
