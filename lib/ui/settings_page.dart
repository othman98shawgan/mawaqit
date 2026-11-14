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
import '../services/nav_style_service.dart';
import '../services/notifications_service.dart';
import '../services/prayer_alarm_service.dart';

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

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  bool _isDevMode = false;
  bool _isBatteryOptIgnored = true;
  int _devTapCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDevMode();
    _loadBatteryOpt();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadBatteryOpt();
    }
  }

  void _loadBatteryOpt() async {
    final ignored = await PrayerAlarmService.isBatteryOptimizationIgnored();
    if (mounted) setState(() => _isBatteryOptIgnored = ignored);
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  CustomSettingsSection _buildVersionSection(String fontFamily, bool isFloatingNav) {
    return CustomSettingsSection(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onVersionTap,
        onLongPress: _onVersionLongPress,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 24, 0, isFloatingNav ? MediaQuery.of(context).padding.bottom + 24 : 24),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.appVersion('1.0.9'),
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

    var citiesList = getCitiesMap(AppLocalizations.of(context)!);

    return Consumer6<ThemeNotifier, DaylightSavingNotifier, ReminderNotifier, DhikrNotifier,
        NotificationsStatusNotifier, LocaleNotifier>(
      builder: (context, theme, daylightSaving, reminder, dhikr, notifications, localeProvider, child) {
        final navStyleNotifier = Provider.of<NavStyleNotifier>(context);
        final isFloatingNav = navStyleNotifier.isFloating;
        final navStyleLabel = isFloatingNav
            ? AppLocalizations.of(context)!.navBarStyleFloating
            : AppLocalizations.of(context)!.navBarStyleDocked;

        return Center(
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
            body: (isAndroid || isWindows || isIOS)
                ? SettingsList(
                    platform: isIOS ? DevicePlatform.android : DevicePlatform.android,
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
                          if (_isDevMode)
                            SettingsTile.navigation(
                              leading: const Icon(Icons.space_dashboard_outlined),
                              title: Text(
                                AppLocalizations.of(context)!.settingsNavBarStyle,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily),
                              ),
                              value: Text(
                                navStyleLabel,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily),
                              ),
                              onPressed: (context) {
                                showNavStyleDialog(context, navStyleNotifier);
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
                          if (isAndroid)
                            SettingsTile.navigation(
                              title: Text(
                                AppLocalizations.of(context)!.alarmSection,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily),
                              ),
                              leading: const Icon(Icons.alarm),
                              onPressed: (context) async {
                                await Navigator.pushNamed(context, '/alarms_settings');
                                _loadBatteryOpt();
                              },
                            ),
                          if (isAndroid && !_isBatteryOptIgnored)
                            SettingsTile.navigation(
                              title: Text(
                                AppLocalizations.of(context)!.disableBatteryOptimization,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600),
                              ),
                              description: Text(
                                AppLocalizations.of(context)!.batteryOptimizationDesc,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily),
                              ),
                              leading: const Icon(Icons.battery_alert, color: Colors.orangeAccent),
                              onPressed: (context) async {
                                final granted = await PrayerAlarmService.requestIgnoreBatteryOptimization();
                                if (mounted) {
                                  setState(() {
                                    _isBatteryOptIgnored = granted;
                                  });
                                }
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
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ]),
                      _buildVersionSection(fontFamily, isFloatingNav),
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
                          if (_isDevMode)
                            SettingsTile.navigation(
                              leading: const Icon(Icons.space_dashboard_outlined),
                              title: Text(
                                AppLocalizations.of(context)!.settingsNavBarStyle,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily),
                              ),
                              value: Text(
                                navStyleLabel,
                                strutStyle: const StrutStyle(forceStrutHeight: true),
                                style: TextStyle(fontFamily: fontFamily),
                              ),
                              onPressed: (context) {
                                showNavStyleDialog(context, navStyleNotifier);
                              },
                            ),
                        ],
                      ),
                      _buildVersionSection(fontFamily, isFloatingNav),
                    ],
                  )),
        ));
      },
    );
  }
}

Future<void> showCitiesDialog(
    BuildContext context, String city, Map<String, String> citiesMap, Function updatePrayers) async {
  final l10n = AppLocalizations.of(context)!;
  final currentCityValue = citiesMap[city];
  final citiesList = citiesMap.values.toList()
    ..sort((a, b) {
      if (a == l10n.alQuds) return -1;
      if (b == l10n.alQuds) return 1;
      if (a.contains(RegExp(r'[0-9]')) && !b.contains(RegExp(r'[0-9]'))) return 1;
      if (b.contains(RegExp(r'[0-9]')) && !a.contains(RegExp(r'[0-9]'))) return -1;
      return a.compareTo(b);
    });

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black87;
  final accentColor = isDark ? darkThemeSwatch : color3;
  final localeProvider = Provider.of<LocaleNotifier>(context, listen: false);
  final textDirection = localeProvider.getTextDirection(localeProvider.locale);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: isDark ? appBarColor : color1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      final maxHeight = MediaQuery.of(sheetContext).size.height * 0.65;
      return Directionality(
        textDirection: textDirection,
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    l10n.citySelect,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: citiesList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final cityLabel = citiesList[index];
                      final isSelected = cityLabel == currentCityValue;
                      return ListTile(
                        title: Text(
                          cityLabel,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        trailing: isSelected ? Icon(Icons.check, color: accentColor) : null,
                        onTap: () {
                          final selectedKey = citiesMap.keys.firstWhere((k) => citiesMap[k] == cityLabel);
                          Navigator.pop(sheetContext);
                          Provider.of<LocaleNotifier>(context, listen: false).setCity(selectedKey);
                          updatePrayers();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showLocaleDialog(BuildContext context, Locale locale, Function updatePrayers) async {
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
                    l10n.languageDialogTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                for (final code in ['ar', 'en'])
                  ListTile(
                    title: Text(
                      localeMap[code]!,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: locale.languageCode == code ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: locale.languageCode == code ? Icon(Icons.check, color: accentColor) : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Provider.of<LocaleNotifier>(context, listen: false).setLocale(Locale(code));
                      updatePrayers();
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

Future<void> showNavStyleDialog(BuildContext context, NavStyleNotifier navStyleNotifier) async {
  final l10n = AppLocalizations.of(context)!;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textColor = isDark ? Colors.white : Colors.black87;
  final accentColor = isDark ? darkThemeSwatch : color3;
  final currentStyle = navStyleNotifier.style;
  final localeProvider = Provider.of<LocaleNotifier>(context, listen: false);
  final textDirection = localeProvider.getTextDirection(localeProvider.locale);

  final options = [
    (style: NavBarStyle.floating, label: l10n.navBarStyleFloating),
    (style: NavBarStyle.docked, label: l10n.navBarStyleDocked),
  ];

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
                    l10n.settingsNavBarStyle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                for (final option in options)
                  ListTile(
                    title: Text(
                      option.label,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: currentStyle == option.style ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: currentStyle == option.style ? Icon(Icons.check, color: accentColor) : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      navStyleNotifier.setStyle(option.style);
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
