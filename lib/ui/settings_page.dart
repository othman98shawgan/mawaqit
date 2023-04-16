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
import 'widgets/reminder_dialog.dart';

var localeMap = {'ar': "العربية", 'en': "English"};

class SettingsPage extends StatefulWidget {
  const SettingsPage({
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
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    var title = AppLocalizations.of(context)!.settingsString;
    var generalSection = AppLocalizations.of(context)!.settingsGeneralSection;
    var languageString = AppLocalizations.of(context)!.settingsLanguage;
    var darkModeString = AppLocalizations.of(context)!.settingsDarkMode;
    var dstString = AppLocalizations.of(context)!.settingsDaylightSaving;
    var summerTimeString = AppLocalizations.of(context)!.settingsSummerTime;
    var winterTimeString = AppLocalizations.of(context)!.settingsWinterTime;
    var notificationsSection = AppLocalizations.of(context)!.settingsNotificationsSection;
    var sendNotificationsString = AppLocalizations.of(context)!.settingsSendNotifications;
    var prayerReminderString = AppLocalizations.of(context)!.settingsPrayerReminder;
    var prayerReminderOffString =
        AppLocalizations.of(context)!.settingsPrayerReminderDescriptionOff;
    var dhikrSection = AppLocalizations.of(context)!.settingsDhikrSection;
    var dhikrVibrateOnTap = AppLocalizations.of(context)!.settingsDhikrVibrateOnTap;
    var dhikrVibrateOnTarget = AppLocalizations.of(context)!.settingsDhikrVibrateOnTarget;
    var targetString = AppLocalizations.of(context)!.settingsTarget;
    var helpSection = AppLocalizations.of(context)!.settingsHelpSection;
    var resetNotificationsString = AppLocalizations.of(context)!.settingsResetNotifications;

    var forceStrutHeightStrutStyle = const StrutStyle(forceStrutHeight: true);

    var summerTimeDescription =
        Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime()
            ? summerTimeString
            : winterTimeString;

    return Consumer6<ThemeNotifier, DaylightSavingNotifier, ReminderNotifier, DhikrNotifier,
        NotificationsStatusNotifier, LocaleNotifier>(
      builder:
          (context, theme, daylightSaving, reminder, dhikr, notifications, localeProvider, child) =>
              Center(
                  child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: SettingsList(
            contentPadding: EdgeInsets.all(0),
            lightTheme: const SettingsThemeData(settingsListBackground: backgroudColor2),
            sections: [
              SettingsSection(
                title: Text(
                  generalSection,
                  strutStyle: const StrutStyle(forceStrutHeight: true),
                ),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.language),
                    title: Text(
                      languageString,
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
                    value: Text(
                      localeMap[localeProvider.locale.toString()]!,
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
                    onPressed: (context) {
                      showLocaleDialog(context, localeProvider.locale);
                    },
                  ),
                  SettingsTile.switchTile(
                    title: Text(
                      darkModeString,
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
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
                    title: Text(
                      dstString,
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
                    description: Text(
                      summerTimeDescription,
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
                    leading: const Icon(Icons.access_time),
                    initialValue: daylightSaving.getSummerTime() == daylightSaving.summer,
                    onToggle: (value) {
                      if (value) {
                        daylightSaving.setSummerTime();
                        summerTimeDescription = summerTimeString;
                        widget.updatePrayers!();
                      } else {
                        daylightSaving.setWinterTime();
                        summerTimeDescription = winterTimeString;
                        widget.updatePrayers!();
                      }
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: Text(
                  notificationsSection,
                  strutStyle: const StrutStyle(forceStrutHeight: true),
                ),
                tiles: [
                  SettingsTile.switchTile(
                    title: Text(
                      sendNotificationsString,
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
                    leading: const Icon(Icons.notifications),
                    initialValue: notifications.getNotificationsStatus() == true,
                    onToggle: (value) {
                      if (value) {
                        notifications.setNotificationsOn();
                        notifications.requestNotification();
                        widget.updatePrayers!();
                      } else {
                        notifications.setNotificationsOff();
                        reminder.setReminderStatus(false);
                        widget.cancelNotifications!();
                      }
                    },
                  ),
                  SettingsTile.navigation(
                    title: Text(
                      prayerReminderString,
                      strutStyle: const StrutStyle(forceStrutHeight: true),
                    ),
                    leading: const Icon(Icons.notification_important_sharp),
                    value: reminder.getReminderStatus()
                        ? Text(
                            AppLocalizations.of(context)!
                                .settingsPrayerReminderDescription(reminder.getReminderTime()),
                            strutStyle: const StrutStyle(forceStrutHeight: true),
                          )
                        : Text(
                            prayerReminderOffString,
                            strutStyle: const StrutStyle(forceStrutHeight: true),
                          ),
                    onPressed: (context) async {
                      await showReminderDialog(
                        context,
                        reminder.getReminderStatus(),
                        reminder.getReminderTime(),
                        widget.updateReminder!,
                        widget.updateAppBar!,
                      );
                    },
                  ),
                ],
              ),
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
              SettingsSection(
                  title: Text(
                    helpSection,
                    strutStyle: const StrutStyle(forceStrutHeight: true),
                  ),
                  tiles: [
                    SettingsTile.navigation(
                      title: Text(resetNotificationsString,strutStyle: const StrutStyle(forceStrutHeight: true),),
                      leading: const Icon(Icons.restart_alt),
                      onPressed: (context) async {
                        widget.updatePrayers!();
                        Navigator.pop(context);
                      },
                    ),
                  ]),
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

showLocaleDialog(BuildContext context, Locale locale) async {
  Locale? currentLocale = locale;

  var confirmMethod = (() {
    Navigator.pop(context);
    Provider.of<LocaleNotifier>(context, listen: false).setLocale(currentLocale!);
  });
  var languageDialogTitle = AppLocalizations.of(context)!.languageDialogTitle;
  var confirmString = AppLocalizations.of(context)!.confirmString;
  var cancelString = AppLocalizations.of(context)!.cancelString;

  AlertDialog alert = AlertDialog(
      title: Text(languageDialogTitle),
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
                    value: const Locale('ar'),
                    title: Text(localeMap['ar']!),
                    groupValue: currentLocale,
                    onChanged: (val) {
                      setState(() {
                        currentLocale = val as Locale?;
                      });
                    }),
                RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity),
                    value: const Locale('en'),
                    title: Text(localeMap['en']!),
                    groupValue: currentLocale,
                    onChanged: (val) {
                      setState(() {
                        currentLocale = val as Locale?;
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
