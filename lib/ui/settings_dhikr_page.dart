import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:alfajr/l10n/app_localizations.dart';

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
  });

  final Function? updatePrayers;
  final Function? updateReminder;
  final Function? cancelNotifications;

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
            lightTheme: const SettingsThemeData(
              settingsListBackground: backgroudColor,
              titleTextColor: color3,
            ),
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

Future<void> showTargetDialog(BuildContext context, int target) async {
  final l10n = AppLocalizations.of(context)!;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black87;
  final accentColor = isDark ? darkThemeSwatch : color3;
  final localeProvider = Provider.of<LocaleNotifier>(context, listen: false);
  final textDirection = localeProvider.getTextDirection(localeProvider.locale);

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: isDark ? appBarColor : color1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return Directionality(
        textDirection: textDirection,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n.targetDialogTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                for (final value in [33, 100])
                  ListTile(
                    title: Text(
                      '$value',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: target == value ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: target == value ? Icon(Icons.check, color: accentColor) : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Provider.of<DhikrNotifier>(context, listen: false).setDhikrCount(value);
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
