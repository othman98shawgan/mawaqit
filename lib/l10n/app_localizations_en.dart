// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'English';

  @override
  String get appName => 'Mawaqit Al-Quds';

  @override
  String get fajrString => 'Fajr';

  @override
  String get shuruqString => 'Shuruq';

  @override
  String get duhrString => 'Duhr';

  @override
  String get asrString => 'Asr';

  @override
  String get maghribString => 'Maghrib';

  @override
  String get ishaString => 'Isha';

  @override
  String timeUntil(String prayer) {
    return 'Time until $prayer:';
  }

  @override
  String timeSince(String prayer) {
    return 'Time since $prayer:';
  }

  @override
  String get calendarString => 'Prayers Calendar';

  @override
  String get todayTooltip => 'Today';

  @override
  String get dstTooltip => 'Daylight Saving Mode';

  @override
  String get prevoiusDayTooltip => 'Prevoius Day';

  @override
  String get nextDayTooltip => 'Next Day';

  @override
  String get qiblaString => 'Qibla';

  @override
  String get ourAppsString => 'Our Apps';

  @override
  String get contactUsString => 'Contact Us';

  @override
  String get shareString => 'Share';

  @override
  String get shareMessageTitle => 'Prayer Times for';

  @override
  String get shareMessageDownload => 'Download Mawaqit Al-Quds using';

  @override
  String get dhikrString => 'Tasbeeh Counter';

  @override
  String get missedPrayersString => 'Missed Prayers';

  @override
  String get notificationsString => 'Notifications';

  @override
  String get cancelPrayersTooltip => 'Cancel Prayers';

  @override
  String get settingsString => 'Settings';

  @override
  String get resetCountTooltip => 'Reset Count';

  @override
  String get missedPrayersClearAll => 'Clear All';

  @override
  String get confirmString => 'Confirm';

  @override
  String get cancelString => 'Cancel';

  @override
  String get closeString => 'Close';

  @override
  String get missedPrayersClearAllMessage =>
      'Are you sure you want to clear all missed prayers?';

  @override
  String get addMissedPrayersTitle => 'Add missed prayers';

  @override
  String get addWeekString => 'Add Week';

  @override
  String get addMonthString => 'Add Month';

  @override
  String get addYearString => 'Add Year';

  @override
  String get reminderDialogTitle => 'Prayer reminder';

  @override
  String get reminderDialogMessage => 'Set prayer reminder';

  @override
  String reminderPrayerMessage(num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return 'Reminder for each prayer: $reminderString';
  }

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDaylightSaving => 'Daylight Saving';

  @override
  String get settingsSummerTime => 'Summer Time';

  @override
  String get settingsWinterTime => 'Winter Time';

  @override
  String get settingsNotificationsSection => 'Notifications';

  @override
  String get settingsSendNotifications => 'Send Notifications';

  @override
  String get settingsPrayerReminder => 'Prayer Reminder';

  @override
  String settingsPrayerReminderDescription(num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return '$reminderString mins';
  }

  @override
  String get settingsPrayerReminderDescriptionOff => 'Off';

  @override
  String get settingsDhikrSection => 'Tasbeeh';

  @override
  String get settingsDhikrVibrateOnTap => 'Vibrate on each Tap';

  @override
  String get settingsDhikrVibrateOnTarget => 'Vibrate on finishing Cycle';

  @override
  String get settingsTarget => 'Cycle length';

  @override
  String settingsTargetDescription(num dhikrTarget) {
    final intl.NumberFormat dhikrTargetNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String dhikrTargetString = dhikrTargetNumberFormat.format(
      dhikrTarget,
    );

    return 'Current Cycle is: $dhikrTargetString';
  }

  @override
  String get settingsHelpSection => 'Help';

  @override
  String get settingsResetNotifications => 'Reset Notifications';

  @override
  String get targetDialogTitle => 'Counter target';

  @override
  String get languageDialogTitle => 'Language';

  @override
  String notificationsPrayerTimeTitle(String prayer) {
    return 'Time for $prayer';
  }

  @override
  String get notificationsShuruqPrayerTimeTitle => 'Time for Shuruq';

  @override
  String get notificationsShuruqBody => 'Duha is in 20 minutes';

  @override
  String notificationsReminderTitle(String prayer, num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return '$prayer Azan is in $reminderString minutes';
  }

  @override
  String notificationsReminderTitleMinutes(String prayer, num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return '$prayer Azan is in $reminderString minutes';
  }

  @override
  String notificationsShuruqReminderTitle(num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return 'Shuruq is in $reminderString minutes';
  }

  @override
  String notificationsShuruqReminderTitleMinutes(num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return 'Shuruq is in $reminderString minutes';
  }

  @override
  String get citySelect => 'Selcet your city';

  @override
  String get cityCurrnet => 'Currnet city';

  @override
  String get alQuds => 'Al-Quds';

  @override
  String get kfarKama => 'Kfar Kama';

  @override
  String get ramallah => 'Ramallah';

  @override
  String get bethlehem => 'Bethlehem';

  @override
  String get jenin => 'Jenin';

  @override
  String get nablus => 'Nablus';

  @override
  String get nazareth => 'Nazareth';

  @override
  String get ummAlFahm => 'Umm al-Fahm';

  @override
  String get jericho => 'Jericho';

  @override
  String get tiberias => 'Tiberias';

  @override
  String get safad => 'Safad';

  @override
  String get beisan => 'Beisan';

  @override
  String get haifa => 'Haifa';

  @override
  String get acre => 'Acre';

  @override
  String get tulkarm => 'Tulkarm';

  @override
  String get kafrQasim => 'Kafr Qasim';

  @override
  String get tayibe => 'Tayibe';

  @override
  String get alKhalil => 'Al-Khalil';

  @override
  String get alLid => 'Al-Lid';

  @override
  String get ramla => 'Ramla';

  @override
  String get qalqilya => 'Qalqilya';

  @override
  String get birAsSaba => 'Bir as-Saba';

  @override
  String get jaffa => 'Jaffa';

  @override
  String get gaza => 'Gaza';

  @override
  String get rafah => 'Rafah';

  @override
  String get khanYunis => 'Khan Yunis';

  @override
  String get deirAlBalah => 'Deir al-Balah';

  @override
  String get min1BeforeAlQuds => '1 minutes before Al-Quds';

  @override
  String get min2BeforeAlQuds => '2 minutes before Al-Quds';

  @override
  String get min3BeforeAlQuds => '3 minutes before Al-Quds';

  @override
  String get min1AfterAlQuds => '1 minutes after Al-Quds';

  @override
  String get min2AfterAlQuds => '2 minutes after Al-Quds';

  @override
  String get min3AfterAlQuds => '3 minutes after Al-Quds';
}
