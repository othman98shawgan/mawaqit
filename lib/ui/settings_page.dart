import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../resources/colors.dart';
import '../services/dhikr_service.dart';
import '../services/theme_service.dart';
import 'widgets/reminder_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title, this.updateSummerTime, this.updateReminder});

  final String title;
  final Function? updateSummerTime;
  final Function? updateReminder;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var summerTimeDesc = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime()
        ? 'Summer Time'
        : 'Winter Time';
    return Consumer4<ThemeNotifier, DaylightSavingNotifier, ReminderNotifier,DhikrNotifier>(
      builder: (context, theme, daylightSaving, reminder,dhikr, child) => Center(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: SettingsList(
            lightTheme: const SettingsThemeData(settingsListBackground: backgroudColor2),
            sections: [
              SettingsSection(
                title: const Text('General'),
                tiles: [
                  SettingsTile.switchTile(
                    title: const Text('Dark Mode'),
                    leading: const Icon(Icons.dark_mode_outlined),
                    initialValue: theme.getTheme() == theme.darkTheme,
                    onToggle: (value) {
                      if (value) {
                        theme.setDarkMode();
                      } else {
                        theme.setLightMode();
                      }
                    },
                  ),
                  SettingsTile.switchTile(
                    title: const Text('Daylight Saving'),
                    description: Text(summerTimeDesc),
                    leading: const Icon(Icons.access_time),
                    initialValue: daylightSaving.getSummerTime() == daylightSaving.summer,
                    onToggle: (value) {
                      if (value) {
                        daylightSaving.setSummerTime();
                        summerTimeDesc = 'Summer Time';
                        widget.updateSummerTime!();
                      } else {
                        daylightSaving.setWinterTime();
                        summerTimeDesc = 'Winter Time';
                        widget.updateSummerTime!();
                      }
                    },
                  ),
                  SettingsTile.navigation(
                    title: const Text('Prayer Reminder'),
                    leading: const Icon(Icons.notifications),
                    value: Text('${reminder.getReminderTime()} mins'),
                    onPressed: (context) async {
                      await showReminderDialog(
                          context, reminder.getReminderTime(), widget.updateReminder!);
                    },
                  ),
                ],
              ),
                            SettingsSection(
                title: const Text('Dhikr'),
                tiles: [
                  SettingsTile.switchTile(
                    title: const Text('Vibrate on each Tap'),
                    leading: const Icon(Icons.vibration),
                    initialValue: dhikr.getVibrateOnTap(),
                    onToggle: (value) {
                      if (value) {
                        dhikr.enableVibrateOnTap();
                      } else {
                        dhikr.disableVibrateOnTap();
                      }
                    },
                  ),
                  SettingsTile.switchTile(
                    title: const Text('Vibrate on reaching Target'),
                    leading: const Icon(Icons.vibration),
                    initialValue: dhikr.getVibrateOnCountTarget(),
                    onToggle: (value) {
                      if (value) {
                        dhikr.enableVibrateOnCountTarget();
                      } else {
                        dhikr.disableVibrateOnCountTarget();
                      }
                    },
                  ),
                  SettingsTile.navigation(
                    enabled: dhikr.getVibrateOnCountTarget(),
                    leading: const Icon(Icons.track_changes),
                    title: const Text('Target'),
                    value: Text('Current target is: ${dhikr.getDhikrTarget()}'),
                    onPressed: (context) {
                      showRoundToDialog(context, dhikr.getDhikrTarget());
                    },
                  ),
                ],
              ),

              SettingsSection(title: const Text('Help'), tiles: [
                SettingsTile.navigation(
                  title: const Text('Reset Notifications'),
                  leading: const Icon(Icons.restart_alt),
                  onPressed: (context) async {
                    widget.updateSummerTime!();
                    Navigator.pop(context);
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

showRoundToDialog(BuildContext context, int target) async {
  int? currentTarget = target;

  var confirmMethod = (() {
    Navigator.pop(context);
    Provider.of<DhikrNotifier>(context, listen: false).setDhikrCount(currentTarget!);
  });

  AlertDialog alert = AlertDialog(
      title: const Text("Counter target"),
      // titlePadding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: confirmMethod,
          child: const Text('Confirm'),
        ),
      ],
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity),
                    value: 33,
                    title: const Text('33'),
                    groupValue: currentTarget,
                    onChanged: (val) {
                      setState(() {
                        currentTarget = (val ?? 0) as int?;
                      });
                    }),
                RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity),
                    value: 100,
                    title: const Text('100'),
                    groupValue: currentTarget,
                    onChanged: (val) {
                      setState(() {
                        currentTarget = (val ?? 0) as int?;
                      });
                    }),
              ],
            ),
          ),
        ]);
      }));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
