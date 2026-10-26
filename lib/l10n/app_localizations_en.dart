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
  String get settingsAutoDst => 'Automatic Daylight Saving';

  @override
  String get settingsAutoDstEnabled => 'Automatic';

  @override
  String get settingsAutoDstDisabled => 'Manual';

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
    final String dhikrTargetString =
        dhikrTargetNumberFormat.format(dhikrTarget);

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

  @override
  String get dstSummerNotificationTitle =>
      'Daylight Saving Time Starts Tomorrow';

  @override
  String get dstSummerNotificationBody =>
      'Clocks will move forward 1 hour tonight. Please be mindful of tomorrow\'s Fajr prayer time.';

  @override
  String get dstWinterNotificationTitle => 'Winter Time Starts Tomorrow';

  @override
  String get dstWinterNotificationBody =>
      'Clocks will move back 1 hour tonight. Please be mindful of tomorrow\'s Fajr prayer time.';

  @override
  String get prayerNotificationChannelName => 'Prayer Times';

  @override
  String get prayerNotificationChannelDescription =>
      'Notifications when prayer time arrives';

  @override
  String get reminderNotificationChannelName => 'Prayer Reminder';

  @override
  String get reminderNotificationChannelDescription =>
      'Reminder notifications before prayer time';

  @override
  String get dstNotificationChannelName => 'Daylight Saving Time';

  @override
  String get dstNotificationChannelDescription =>
      'Notifications for daylight saving time transitions';

  @override
  String developerModeSteps(int count) {
    return 'You are $count steps away from developer mode';
  }

  @override
  String get developerModeEnabled => 'Developer mode enabled!';

  @override
  String get developerModeDisabled => 'Developer mode disabled';

  @override
  String get notificationTesting => 'Notification Testing';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get testFajrTitle => 'Test Fajr Azan';

  @override
  String get testFajrBody => 'It is now time for Fajr prayer';

  @override
  String get dateNotSpecified => 'Date not specified';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get dueNow => 'Due now';

  @override
  String inDaysHours(int days, int hours) {
    return 'in ${days}d ${hours}h';
  }

  @override
  String inDays(int days) {
    return 'in ${days}d';
  }

  @override
  String inHoursMinutes(int hours, int minutes) {
    return 'in ${hours}h ${minutes}m';
  }

  @override
  String inHours(int hours) {
    return 'in ${hours}h';
  }

  @override
  String inMinutes(int minutes) {
    return 'in ${minutes}m';
  }

  @override
  String inSeconds(int seconds) {
    return 'in ${seconds}s';
  }

  @override
  String get testNotificationTitle => 'Test Notification';

  @override
  String get testNotificationBody => 'This is a test notification';

  @override
  String get testScheduledNotificationTitle => 'Scheduled Test Notification';

  @override
  String get testScheduledNotificationBody =>
      'This is a scheduled test notification';

  @override
  String get instantNotificationSent => 'Instant notification sent';

  @override
  String notificationScheduledInSeconds(int seconds) {
    return 'Notification scheduled in $seconds seconds';
  }

  @override
  String notificationCancelled(int id) {
    return 'Cancelled notification ($id)';
  }

  @override
  String get allNotificationsCancelled => 'All notifications cancelled';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get statusGranted => 'Granted';

  @override
  String get statusPermanentlyDenied => 'Permanently Denied';

  @override
  String get statusDenied => 'Denied';

  @override
  String get statusRestricted => 'Restricted';

  @override
  String get notificationPermissionStatus => 'Notification Permission';

  @override
  String get notificationPermissionDescription =>
      'Android and iOS require permission to display notifications and azan at prayer times.';

  @override
  String get requestPermission => 'Request Permission';

  @override
  String get appSettings => 'App Settings';

  @override
  String get exactAlarmsPermission => 'Exact Alarms Permission';

  @override
  String get exactAlarmsDescription =>
      'Android 12+ requires a special permission to schedule azan and reminders at exact minutes.';

  @override
  String get requestExactAlarmsPermission => 'Request Exact Alarm Permission';

  @override
  String get sendTestNotificationSection => 'Send Test Notification';

  @override
  String get notificationTitleLabel => 'Notification Title';

  @override
  String get notificationBodyLabel => 'Notification Body';

  @override
  String get scheduleDelayLabel => 'Schedule Delay:';

  @override
  String get oneMinute => '1 min';

  @override
  String secondsCount(int seconds) {
    return '${seconds}s';
  }

  @override
  String get sendInstant => 'Send Instant';

  @override
  String get schedule => 'Schedule';

  @override
  String get activePendingNotifications => 'Active Pending Notifications';

  @override
  String get activePendingNotificationsDescription =>
      'List of notifications currently registered with the OS awaiting trigger time.';

  @override
  String get noPendingNotifications => 'No pending notifications';

  @override
  String get untitled => 'Untitled';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get cancelAllNotifications => 'Cancel All Notifications';

  @override
  String get contactUsEmailSubject => 'Mawaqit Al-Quds App';

  @override
  String get contactUsEmailBody => 'Peace be upon you,\n';

  @override
  String get daylightSavingDialogTitle => 'Daylight saving time';

  @override
  String get daylightSavingStatus => 'Daylight saving time is: ';
}
