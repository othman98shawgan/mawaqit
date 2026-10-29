import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alfajr/l10n/app_localizations.dart';

import '../../models/prayer_alarm.dart';
import '../../resources/colors.dart';
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

class _AlarmDialogState extends State<AlarmDialog> {
  bool _isLoading = true;
  late PrayerAlarmSettings _settings;
  bool _batteryOptimizationIgnored = true;

  final List<int> _offsetOptions = [0, -10, -15, -20, -30, -45, -60];
  final List<String> _soundOptions = ['alaqsa', 'makkah', 'madina', 'abdulbasit', 'minshawi', 'hussary', 'nafees', 'chime', 'system'];
  final List<int> _snoozeOptions = [0, 5, 10, 15];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loaded = await PrayerAlarmService.loadAlarmSettings(widget.prayerName);
    final ignored = await PrayerAlarmService.isBatteryOptimizationIgnored();
    if (mounted) {
      setState(() {
        _settings = loaded;
        _batteryOptimizationIgnored = ignored;
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
    final prayerTitle = getPrayerTranslation(widget.prayerName, context);
    await PrayerAlarmService.saveAlarmSettings(_settings);

    if (_settings.isEnabled) {
      await PrayerAlarmService.schedulePrayerAlarm(
        prayerName: widget.prayerName,
        prayerTime: widget.prayerTime,
        settings: _settings,
        title: l10n.alarmRingingTitle(prayerTitle),
        body: prayerTitle,
        dismissLabel: l10n.alarmDismiss,
        snoozeLabel: l10n.alarmSnooze,
      );
    } else {
      await PrayerAlarmService.cancelAlarm(widget.prayerName);
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
              activeColor: prayerColor,
              onChanged: (val) {
                setState(() {
                  _settings = _settings.copyWith(isEnabled: val);
                });
              },
            ),
            const Divider(),

            if (_settings.isEnabled) ...[
              // Alarm Time / Offset
              Text(
                l10n.alarmOffset,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _offsetOptions.contains(_settings.offsetMinutes) ? _settings.offsetMinutes : 0,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _offsetOptions.map((offset) {
                  return DropdownMenuItem<int>(
                    value: offset,
                    child: Text(_getOffsetTitle(offset, l10n)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _settings = _settings.copyWith(offsetMinutes: val);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Sound Selection
              Text(
                l10n.alarmSound,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _soundOptions.contains(_settings.soundType) ? _settings.soundType : 'alaqsa',
                isExpanded: true,
                decoration: const InputDecoration(
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
              Text(
                l10n.alarmSnoozeDuration,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _snoozeOptions.contains(_settings.snoozeMinutes) ? _settings.snoozeMinutes : 10,
                isExpanded: true,
                decoration: const InputDecoration(
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
