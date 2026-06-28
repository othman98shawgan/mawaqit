import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../resources/colors.dart';
import '../services/dhikr_service.dart';
import '../services/notifications_service.dart';
import '../services/theme_service.dart';

class SettingsDhikrPage extends StatefulWidget {
  const SettingsDhikrPage({
    super.key,
    this.updatePrayers,
    this.updateReminder,
    this.cancelNotifications,
    this.updateAppBar,
  });

  final Function? updatePrayers;
  final Function? updateReminder;
  final Function? cancelNotifications;
  final Function? updateAppBar;

  @override
  State<SettingsDhikrPage> createState() => _SettingsDhikrPageState();
}

class _SettingsDhikrPageState extends State<SettingsDhikrPage> {
  @override
  Widget build(BuildContext context) {
    var title = AppLocalizations.of(context)!.settingsString;
    var dhikrSection = AppLocalizations.of(context)!.settingsDhikrSection;
    var dhikrVibrateOnTap = AppLocalizations.of(context)!.settingsDhikrVibrateOnTap;
    var dhikrVibrateOnTarget = AppLocalizations.of(context)!.settingsDhikrVibrateOnTarget;
    var targetString = AppLocalizations.of(context)!.settingsTarget;

    return Consumer6<ThemeNotifier, DaylightSavingNotifier, ReminderNotifier, DhikrNotifier,
        NotificationsStatusNotifier, LocaleNotifier>(
      builder:
          (context, theme, daylightSaving, reminder, dhikr, notifications, localeProvider, child) =>
              Center(
                  child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          body: SettingsList(
            contentPadding: const EdgeInsets.all(0),
            lightTheme: const SettingsThemeData(settingsListBackground: backgroudColor),
            sections: [
              SettingsSection(
                title: Text(
                  dhikrSection,
                  strutStyle: const StrutStyle(forceStrutHeight: true),
                ),
                tiles: [
                  SettingsTile.switchTile(
                    title: Text(
                      dhikrVibrateOnTap,
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
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
                    title: Text(
                      dhikrVibrateOnTarget,
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
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
                    title: Text(
                      targetString,
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
                    value: Text(
                      AppLocalizations.of(context)!
                          .settingsTargetDescription(dhikr.getDhikrTarget()),
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
                    onPressed: (context) {
                      showTargetDialog(context, dhikr.getDhikrTarget());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}

showTargetDialog(BuildContext context, int target) async {
  int? currentTarget = target;

  var confirmMethod = (() {
    Navigator.pop(context);
    Provider.of<DhikrNotifier>(context, listen: false).setDhikrCount(currentTarget!);
  });

  var targetDialogTitle = AppLocalizations.of(context)!.targetDialogTitle;
  var confirmString = AppLocalizations.of(context)!.confirmString;
  var cancelString = AppLocalizations.of(context)!.cancelString;

  AlertDialog alert = AlertDialog(
      title: Text(targetDialogTitle),
      // titlePadding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(cancelString)),
        TextButton(
          onPressed: confirmMethod,
          child: Text(confirmString),
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
