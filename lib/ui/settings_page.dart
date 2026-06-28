import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mawaqit/l10n/app_localizations.dart';

import '../providers/notifications_status_notifier.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../services/daylight_time_service.dart';
import '../services/reminder_service.dart';
import 'widgets/reminder_dialog.dart';

var localeMap = {'ar': "العربية", 'en': "English"};

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch state
    final theme = context.watch<ThemeNotifier>();
    final daylightSaving = context.watch<DaylightSavingNotifier>();
    final reminder = context.watch<ReminderNotifier>();
    final notifications = context.watch<NotificationsStatusNotifier>();
    final localeProvider = context.watch<LocaleNotifier>();

    // Localizations
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
    var summerTimeDescription = daylightSaving.getSummerTime() == daylightSaving.summer
        ? summerTimeString
        : winterTimeString;

    const fontFamily = 'Tajawal';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // General Section
          _buildSectionHeader(context, generalSection, fontFamily),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(languageString, style: const TextStyle(fontFamily: fontFamily)),
                  subtitle: Text(localeMap[localeProvider.locale.languageCode] ?? 'Unknown', style: const TextStyle(fontFamily: fontFamily)),
                  onTap: () {
                    showLocaleDialog(context, localeProvider.locale);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(darkModeString, style: const TextStyle(fontFamily: fontFamily)),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: theme.themeMode == ThemeMode.dark,
                  onChanged: (bool value) {
                    if (value) {
                      theme.setDarkMode();
                    } else {
                      theme.setLightMode();
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(dstString, style: const TextStyle(fontFamily: fontFamily)),
                  subtitle: Text(summerTimeDescription, style: const TextStyle(fontFamily: fontFamily)),
                  secondary: const Icon(Icons.access_time),
                  value: daylightSaving.getSummerTime() == daylightSaving.summer,
                  onChanged: (bool value) {
                    if (value) {
                      daylightSaving.setSummerTime();
                    } else {
                      daylightSaving.setWinterTime();
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(citySlecetionString, style: const TextStyle(fontFamily: fontFamily)),
                  subtitle: Text('$cityDescriptionString: ${citiesList[localeProvider.city]!}', style: const TextStyle(fontFamily: fontFamily)),
                  onTap: () {
                    showCitiesDialog(context, localeProvider.city, citiesList);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(context, notificationsSection, fontFamily),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(sendNotificationsString, style: const TextStyle(fontFamily: fontFamily)),
                  secondary: const Icon(Icons.notifications),
                  value: notifications.isAllowed,
                  onChanged: (bool value) async {
                    if (value) {
                      await notifications.requestPermissions();
                    } else {
                      await notifications.requestPermissions();
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notification_important_sharp),
                  title: Text(prayerReminderString, style: const TextStyle(fontFamily: fontFamily)),
                  subtitle: reminder.getReminderStatus()
                      ? Text(AppLocalizations.of(context)!.settingsPrayerReminderDescription(reminder.getReminderTime()), style: const TextStyle(fontFamily: fontFamily))
                      : Text(prayerReminderOffString, style: const TextStyle(fontFamily: fontFamily)),
                  onTap: () async {
                    await showReminderDialog(
                      context,
                      reminder.getReminderStatus(),
                      reminder.getReminderTime(),
                      (int value) {
                        context.read<ReminderNotifier>().setReminderTime(value);
                      },
                      (bool showAppbar) {}, 
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Help Section
          _buildSectionHeader(context, helpSection, fontFamily),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.restart_alt),
              title: Text(resetNotificationsString, style: const TextStyle(fontFamily: fontFamily)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String fontFamily) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontFamily: fontFamily,
            ),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// DIALOGS
// -------------------------------------------------------------------------

void showCitiesDialog(BuildContext context, String currentCityId, Map<String, String> citiesMap) {
  var currentCityValue = citiesMap.values.firstWhere((element) => element == citiesMap[currentCityId]);

  int selected = 0;
  var citiesList = citiesMap.values.toList();
  
  citiesList.sort((a, b) {
    if (a == AppLocalizations.of(context)!.alQuds) return -1;
    if (b == AppLocalizations.of(context)!.alQuds) return 1;
    if (a.contains(RegExp(r'[0-9]')) && !b.contains(RegExp(r'[0-9]'))) return 1;
    if (b.contains(RegExp(r'[0-9]')) && !a.contains(RegExp(r'[0-9]'))) return -1;
    return a.compareTo(b);
  });

  for (int i = 0; i < citiesList.length; i++) {
    if (citiesList[i] == currentCityValue) {
      selected = i;
      break;
    }
  }

  var cityDialogTitle = AppLocalizations.of(context)!.citySelect;
  var confirmString = AppLocalizations.of(context)!.confirmString;
  var cancelString = AppLocalizations.of(context)!.cancelString;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(cityDialogTitle, style: const TextStyle(fontFamily: 'Tajawal')),
        contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext), child: Text(cancelString, style: const TextStyle(fontFamily: 'Tajawal'))),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              String selectedCityKey = citiesMap.keys.firstWhere((key) => citiesMap[key] == citiesList[selected]);
              context.read<LocaleNotifier>().setCity(selectedCityKey);
            },
            child: Text(confirmString, style: const TextStyle(fontFamily: 'Tajawal')),
          ),
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
                              title: Text(citiesList.elementAt(index), style: const TextStyle(fontFamily: 'Tajawal')),
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
        }),
      );
    },
  );
}

void showLocaleDialog(BuildContext context, Locale currentLocale) {
  Locale? tempLocale = currentLocale;

  var languageDialogTitle = AppLocalizations.of(context)!.languageDialogTitle;
  var confirmString = AppLocalizations.of(context)!.confirmString;
  var cancelString = AppLocalizations.of(context)!.cancelString;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(languageDialogTitle, style: const TextStyle(fontFamily: 'Tajawal')),
        contentPadding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext), child: Text(cancelString, style: const TextStyle(fontFamily: 'Tajawal'))),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (tempLocale != null) {
                context.read<LocaleNotifier>().setLocale(tempLocale!);
              }
            },
            child: Text(confirmString, style: const TextStyle(fontFamily: 'Tajawal')),
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
                      visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                      value: const Locale('ar'),
                      title: Text(localeMap['ar']!, style: const TextStyle(fontFamily: 'Tajawal')),
                      groupValue: tempLocale,
                      onChanged: (val) {
                        setState(() {
                          tempLocale = val as Locale?;
                        });
                      }),
                  RadioListTile(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                      value: const Locale('en'),
                      title: Text(localeMap['en']!, style: const TextStyle(fontFamily: 'Tajawal')),
                      groupValue: tempLocale,
                      onChanged: (val) {
                        setState(() {
                          tempLocale = val as Locale?;
                        });
                      }),
                ],
              ),
            ),
          ]);
        }),
      );
    },
  );
}
