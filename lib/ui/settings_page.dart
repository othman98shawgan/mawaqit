import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:alfajr/l10n/app_localizations.dart';

import '../main.dart';
import '../resources/colors.dart';
import '../services/dhikr_service.dart';
import '../services/notifications_service.dart';

import '../services/store_manager.dart';
import '../services/theme_service.dart';
import 'widgets/reminder_dialog.dart';

var localeMap = {'ar': "العربية", 'en': "English"};

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.updatePrayers,
    this.updateReminder,
    this.cancelNotifications,
  });

  final Function? updatePrayers;
  final Function? updateReminder;
  final Function? cancelNotifications;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDevMode = false;
  int _devTapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDevMode();
  }

  void _loadDevMode() async {
    final dev = await StorageManager.readData('isDevMode');
    if (dev is bool && dev) {
      if (mounted) setState(() => _isDevMode = true);
    }
  }

  void _onVersionTap() {
    if (_isDevMode) return;
    _devTapCount++;
    final remaining = 7 - _devTapCount;
    if (remaining <= 3 && remaining > 0) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.developerModeSteps(remaining)),
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (remaining <= 0) {
      setState(() {
        _isDevMode = true;
      });
      StorageManager.saveData('isDevMode', true);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.developerModeEnabled),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onVersionLongPress() {
    if (!_isDevMode) return;
    setState(() {
      _isDevMode = false;
      _devTapCount = 0;
    });
    StorageManager.saveData('isDevMode', false);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.developerModeDisabled),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  CustomSettingsSection _buildVersionSection(String fontFamily) {
    return CustomSettingsSection(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onVersionTap,
        onLongPress: _onVersionLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.appVersion('1.0.8'),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
    var prayerReminderOffString = AppLocalizations.of(context)!.settingsPrayerReminderDescriptionOff;
    var helpSection = AppLocalizations.of(context)!.settingsHelpSection;
    var resetNotificationsString = AppLocalizations.of(context)!.settingsResetNotifications;
    var citySlecetionString = AppLocalizations.of(context)!.citySelect;
    var cityDescriptionString = AppLocalizations.of(context)!.cityCurrnet;
    var summerTimeDescription = Provider.of<DaylightSavingNotifier>(context, listen: false).getSummerTime()
        ? summerTimeString
        : winterTimeString;

    var fontFamily = 'Tajawal';

    var citiesList = {
      'alQuds': AppLocalizations.of(context)!.alQuds,
      'kfarKama': AppLocalizations.of(context)!.kfarKama,
      'ramallah': AppLocalizations.of(context)!.ramallah,
      'bethlehem': AppLocalizations.of(context)!.bethlehem,
      'jenin': AppLocalizations.of(context)!.jenin,
      'nablus': AppLocalizations.of(context)!.nablus,
      'nazareth': AppLocalizations.of(context)!.nazareth,
      'ummAlFahm': AppLocalizations.of(context)!.ummAlFahm,
      'jericho': AppLocalizations.of(context)!.jericho,
      'tiberias': AppLocalizations.of(context)!.tiberias,
      'safad': AppLocalizations.of(context)!.safad,
      'beisan': AppLocalizations.of(context)!.beisan,
      'haifa': AppLocalizations.of(context)!.haifa,
      'acre': AppLocalizations.of(context)!.acre,
      'tulkarm': AppLocalizations.of(context)!.tulkarm,
      'kafrQasim': AppLocalizations.of(context)!.kafrQasim,
      'tayibe': AppLocalizations.of(context)!.tayibe,
      'alKhalil': AppLocalizations.of(context)!.alKhalil,
      'alLid': AppLocalizations.of(context)!.alLid,
      'ramla': AppLocalizations.of(context)!.ramla,
      'qalqilya': AppLocalizations.of(context)!.qalqilya,
      'birAsSaba': AppLocalizations.of(context)!.birAsSaba,
      'jaffa': AppLocalizations.of(context)!.jaffa,
      'gaza': AppLocalizations.of(context)!.gaza,
      'rafah': AppLocalizations.of(context)!.rafah,
      'khanYunis': AppLocalizations.of(context)!.khanYunis,
      'deirAlBalah': AppLocalizations.of(context)!.deirAlBalah,
      'min1BeforeAlQuds': AppLocalizations.of(context)!.min1BeforeAlQuds,
      'min2BeforeAlQuds': AppLocalizations.of(context)!.min2BeforeAlQuds,
      'min3BeforeAlQuds': AppLocalizations.of(context)!.min3BeforeAlQuds,
      'min1AfterAlQuds': AppLocalizations.of(context)!.min1AfterAlQuds,
      'min2AfterAlQuds': AppLocalizations.of(context)!.min2AfterAlQuds,
      'min3AfterAlQuds': AppLocalizations.of(context)!.min3AfterAlQuds,
    };

    return Consumer6<ThemeNotifier, DaylightSavingNotifier, ReminderNotifier, DhikrNotifier,
        NotificationsStatusNotifier, LocaleNotifier>(
      builder: (context, theme, daylightSaving, reminder, dhikr, notifications, localeProvider, child) => Center(
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
            body: (isAndroid || isWindows)
                ? SettingsList(
                    platform: DevicePlatform.android,
                    contentPadding: const EdgeInsets.all(0),
                    lightTheme: SettingsThemeData(
                      settingsListBackground: color2.withValues(alpha: 0.2),
                      titleTextColor: color3,
                    ),
                    sections: [
                      SettingsSection(
                        title: Text(generalSection,
                            strutStyle: const StrutStyle(forceStrutHeight: true),
                            style: TextStyle(fontFamily: fontFamily)),
                        tiles: [
                          SettingsTile.navigation(
                            leading: const Icon(Icons.language),
                            title: Text(
                              languageString,
                              strutStyle: const StrutStyle(forceStrutHeight: true),
                              style: TextStyle(fontFamily: fontFamily),
                            ),
                            value: Text(localeMap[localeProvider.locale.toString()]!,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
                            onPressed: (context) {
                              showLocaleDialog(context, localeProvider.locale, widget.updatePrayers!);
                            },
                          ),
                          SettingsTile.switchTile(
                            title: Text(darkModeString,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
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
                            title: Text(AppLocalizations.of(context)!.settingsAutoDst,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
                            description: Text(
                                daylightSaving.isAutoDst
                                    ? '${AppLocalizations.of(context)!.settingsAutoDstEnabled} (${daylightSaving.getSummerTime() ? summerTimeString : winterTimeString})'
                                    : AppLocalizations.of(context)!.settingsAutoDstDisabled,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
                            leading: const Icon(Icons.update),
                            initialValue: daylightSaving.isAutoDst,
                            onToggle: (value) {
                              daylightSaving.setAutoDst(value);
                              widget.updatePrayers!();
                            },
                          ),
                          if (!daylightSaving.isAutoDst)
                            SettingsTile.switchTile(
                              title: Text(dstString,
                                  strutStyle: const StrutStyle(forceStrutHeight: true),
                                  style: TextStyle(fontFamily: fontFamily)),
                              description: Text(summerTimeDescription,
                                  strutStyle: const StrutStyle(forceStrutHeight: true),
                                  style: TextStyle(fontFamily: fontFamily)),
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
                          SettingsTile.navigation(
                            leading: const Icon(Icons.location_city),
                            title: Text(
                              citySlecetionString,
                              strutStyle: const StrutStyle(forceStrutHeight: true),
                              style: TextStyle(fontFamily: fontFamily),
                            ),
                            value: Text('$cityDescriptionString: ${citiesList[localeProvider.city]!}',
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
                            onPressed: (context) {
                              showCitiesDialog(context, localeProvider.city, citiesList, widget.updatePrayers!);
                            },
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: Text(notificationsSection,
                            strutStyle: const StrutStyle(forceStrutHeight: true),
                            style: TextStyle(fontFamily: fontFamily)),
                        tiles: [
                          SettingsTile.switchTile(
                            title: Text(sendNotificationsString,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
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
                            title: Text(prayerReminderString,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
                            leading: const Icon(Icons.notification_important_sharp),
                            value: reminder.getReminderStatus()
                                ? Text(
                                    AppLocalizations.of(context)!
                                        .settingsPrayerReminderDescription(reminder.getReminderTime()),
                                    strutStyle: const StrutStyle(forceStrutHeight: true),
                                    style: TextStyle(fontFamily: fontFamily))
                                : Text(prayerReminderOffString,
                                    strutStyle: const StrutStyle(forceStrutHeight: true),
                                    style: TextStyle(fontFamily: fontFamily)),
                            onPressed: (context) async {
                              await showReminderDialog(
                                context,
                                reminder.getReminderStatus(),
                                reminder.getReminderTime(),
                                widget.updateReminder!,
                              );
                            },
                          ),
                          if (_isDevMode)
                            SettingsTile.navigation(
                              title: Text(
                                AppLocalizations.of(context)!.notificationTesting,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily),
                              ),
                              leading: const Icon(Icons.bug_report_outlined),
                              onPressed: (context) {
                                Navigator.pushNamed(context, '/notification_test');
                              },
                            ),
                        ],
                      ),
                      SettingsSection(
                          title: Text(helpSection,
                              strutStyle: const StrutStyle(forceStrutHeight: true),
                              style: TextStyle(fontFamily: fontFamily)),
                          tiles: [
                            SettingsTile.navigation(
                              title: Text(resetNotificationsString,
                                  strutStyle: const StrutStyle(forceStrutHeight: true),
                                  style: TextStyle(fontFamily: fontFamily)),
                              leading: const Icon(Icons.restart_alt),
                              onPressed: (context) async {
                                widget.updatePrayers!();
                                Navigator.pop(context);
                              },
                            ),
                          ]),
                      _buildVersionSection(fontFamily),
                    ],
                  )
                : SettingsList(
                    platform: DevicePlatform.android,
                    contentPadding: const EdgeInsets.all(0),
                    lightTheme: SettingsThemeData(
                      settingsListBackground: color2.withValues(alpha: 0.2),
                      titleTextColor: color3,
                    ),
                    sections: [
                      SettingsSection(
                        title: Text(generalSection,
                            strutStyle: const StrutStyle(forceStrutHeight: true),
                            style: TextStyle(fontFamily: fontFamily)),
                        tiles: [
                          SettingsTile.navigation(
                            leading: const Icon(Icons.language),
                            title: Text(
                              languageString,
                              strutStyle: const StrutStyle(forceStrutHeight: true),
                              style: TextStyle(fontFamily: fontFamily),
                            ),
                            value: Text(localeMap[localeProvider.locale.toString()]!,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
                            onPressed: (context) {
                              showLocaleDialog(context, localeProvider.locale, widget.updatePrayers!);
                            },
                          ),
                          SettingsTile.switchTile(
                            title: Text(darkModeString,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
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
                            title: Text(AppLocalizations.of(context)!.settingsAutoDst,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
                            description: Text(
                                daylightSaving.isAutoDst
                                    ? '${AppLocalizations.of(context)!.settingsAutoDstEnabled} (${daylightSaving.getSummerTime() ? summerTimeString : winterTimeString})'
                                    : AppLocalizations.of(context)!.settingsAutoDstDisabled,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
                            leading: const Icon(Icons.update),
                            initialValue: daylightSaving.isAutoDst,
                            onToggle: (value) {
                              daylightSaving.setAutoDst(value);
                              widget.updatePrayers!();
                            },
                          ),
                          if (!daylightSaving.isAutoDst)
                            SettingsTile.switchTile(
                              title: Text(dstString,
                                  strutStyle: const StrutStyle(forceStrutHeight: true),
                                  style: TextStyle(fontFamily: fontFamily)),
                              description: Text(summerTimeDescription,
                                  strutStyle: const StrutStyle(forceStrutHeight: true),
                                  style: TextStyle(fontFamily: fontFamily)),
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
                          SettingsTile.navigation(
                            leading: const Icon(Icons.location_city),
                            title: Text(
                              citySlecetionString,
                              strutStyle: const StrutStyle(forceStrutHeight: true),
                              style: TextStyle(fontFamily: fontFamily),
                            ),
                            value: Text('$cityDescriptionString: ${citiesList[localeProvider.city]!}',
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily)),
                            onPressed: (context) {
                              showCitiesDialog(context, localeProvider.city, citiesList, widget.updatePrayers!);
                            },
                          ),
                        ],
                      ),
                      _buildVersionSection(fontFamily),
                    ],
                  )),
      )),
    );
  }
}

Future<void> showCitiesDialog(
    BuildContext context, String city, Map<String, String> citiesMap, Function updatePrayers) async {
  String currentCity = city;
  var currentCityValue = citiesMap.values.firstWhere((element) => element == citiesMap[currentCity]);

  int selected = 0;

  var citiesList = citiesMap.values.toList();
  citiesList.sort((a, b) {
    if (a == AppLocalizations.of(context)!.alQuds) {
      return -1;
    } else if (b == AppLocalizations.of(context)!.alQuds) {
      return 1;
    }
    if (a.contains(RegExp(r'[0-9]')) && !b.contains(RegExp(r'[0-9]'))) {
      return 1;
    }
    if (b.contains(RegExp(r'[0-9]')) && !a.contains(RegExp(r'[0-9]'))) {
      return -1;
    }
    return a.compareTo(b);
  });

  for (int i = 0; i < citiesList.length; i++) {
    if (citiesList[i] == currentCityValue) {
      selected = i;
      break;
    }
  }

  var confirmMethod = (() async {
    Navigator.pop(context);
    currentCity = citiesMap.keys.firstWhere((element) => citiesMap[element] == citiesList[selected]);
    Provider.of<LocaleNotifier>(context, listen: false).setCity(currentCity);
    updatePrayers();
  });
  var cityDialogTitle = AppLocalizations.of(context)!.citySelect;
  var confirmString = AppLocalizations.of(context)!.confirmString;
  var cancelString = AppLocalizations.of(context)!.cancelString;
  var isLight = Theme.of(context).brightness == Brightness.light;
  var textColor = isLight ? Colors.black : Colors.white;

  AlertDialog alert = AlertDialog(
      title: Text(cityDialogTitle, style: TextStyle(color: textColor)),
      // titlePadding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(cancelString)),
        ElevatedButton(onPressed: confirmMethod, child: Text(confirmString)),
      ],
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: citiesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return RadioListTile(
                            title: Text(citiesList.elementAt(index), style: TextStyle(color: textColor)),
                            activeColor: isLight ? color3 : darkThemeSwatch,
                            value: index,
                            groupValue: selected,
                            onChanged: (value) {
                              setState(() {
                                selected = index;
                              });
                            });
                      }),
                ),
              ],
            ),
          ),
        );
      }));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<void> showLocaleDialog(BuildContext context, Locale locale, Function updatePrayers) async {
  Locale? currentLocale = locale;

  var confirmMethod = (() async {
    Navigator.pop(context);
    Provider.of<LocaleNotifier>(context, listen: false).setLocale(currentLocale!);
    updatePrayers();
  });
  var languageDialogTitle = AppLocalizations.of(context)!.languageDialogTitle;
  var confirmString = AppLocalizations.of(context)!.confirmString;
  var cancelString = AppLocalizations.of(context)!.cancelString;
  var isLight = Theme.of(context).brightness == Brightness.light;
  var textColor = isLight ? Colors.black : Colors.white;

  AlertDialog alert = AlertDialog(
      title: Text(languageDialogTitle, style: TextStyle(color: textColor)),
      // titlePadding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0),
      contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(cancelString)),
        ElevatedButton(onPressed: confirmMethod, child: Text(confirmString)),
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
                        horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                    value: const Locale('ar'),
                    activeColor: isLight ? color3 : darkThemeSwatch,
                    title: Text(localeMap['ar']!, style: TextStyle(color: textColor)),
                    groupValue: currentLocale,
                    onChanged: (val) {
                      setState(() {
                        currentLocale = val;
                      });
                    }),
                RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                    value: const Locale('en'),
                    activeColor: isLight ? color3 : darkThemeSwatch,
                    title: Text(localeMap['en']!, style: TextStyle(color: textColor)),
                    groupValue: currentLocale,
                    onChanged: (val) {
                      setState(() {
                        currentLocale = val;
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
