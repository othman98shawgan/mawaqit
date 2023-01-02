import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../resources/colors.dart';
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
    // Full screen width and height
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Height (without SafeArea)
    var padding = MediaQuery.of(context).viewPadding;

    // Height (without status and toolbar)
    double height3 = height - padding.top - kToolbarHeight;
    var summerTimeDesc = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime()
        ? 'Summer Time'
        : 'Winter Time';
    return Consumer3<ThemeNotifier, DaylightSavingNotifier, ReminderNotifier>(
      builder: (context, theme, daylightSaving, reminder, child) => Center(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: SettingsList(
            lightTheme: const SettingsThemeData(settingsListBackground: backgroudColor),
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
              SettingsSection(title: const Text('Help'), tiles: [
                SettingsTile.navigation(
                  title: const Text('Reset'),
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
