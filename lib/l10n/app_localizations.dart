import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// The current Language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// The name of the app
  ///
  /// In en, this message translates to:
  /// **'Mawaqit Al-Quds'**
  String get appName;

  /// Fajr string
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajrString;

  /// Shuruq string
  ///
  /// In en, this message translates to:
  /// **'Shuruq'**
  String get shuruqString;

  /// Duhr prayer string
  ///
  /// In en, this message translates to:
  /// **'Duhr'**
  String get duhrString;

  /// Asr prayer string
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asrString;

  /// Maghrib prayer string
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghribString;

  /// Isha prayer string
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get ishaString;

  /// Time until prayer string
  ///
  /// In en, this message translates to:
  /// **'Time until {prayer}:'**
  String timeUntil(String prayer);

  /// Time since prayer string
  ///
  /// In en, this message translates to:
  /// **'Time since {prayer}:'**
  String timeSince(String prayer);

  /// Calendar page title string
  ///
  /// In en, this message translates to:
  /// **'Prayers Calendar'**
  String get calendarString;

  /// Today icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTooltip;

  /// Daylight Saving Mode icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Daylight Saving Mode'**
  String get dstTooltip;

  /// Prevoius Day icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Prevoius Day'**
  String get prevoiusDayTooltip;

  /// Next Day icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Next Day'**
  String get nextDayTooltip;

  /// Qibla page title string
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaString;

  /// Our Apps page title string
  ///
  /// In en, this message translates to:
  /// **'Our Apps'**
  String get ourAppsString;

  /// Contact Us page title string
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsString;

  /// Share navigation drawer string
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareString;

  /// Share message title
  ///
  /// In en, this message translates to:
  /// **'Prayer Times for'**
  String get shareMessageTitle;

  /// Share message download
  ///
  /// In en, this message translates to:
  /// **'Download Mawaqit Al-Quds using'**
  String get shareMessageDownload;

  /// Dhikr Counter page title string
  ///
  /// In en, this message translates to:
  /// **'Tasbeeh Counter'**
  String get dhikrString;

  /// Missed Prayers page title string
  ///
  /// In en, this message translates to:
  /// **'Missed Prayers'**
  String get missedPrayersString;

  /// Notifications icon string
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsString;

  /// Cancel Prayers icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Cancel Prayers'**
  String get cancelPrayersTooltip;

  /// Settings page title string
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsString;

  /// Reset Count icon tooltip
  ///
  /// In en, this message translates to:
  /// **'Reset Count'**
  String get resetCountTooltip;

  /// Missed Prayers clear all button
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get missedPrayersClearAll;

  /// Confirm button string
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmString;

  /// Cancel button string
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelString;

  /// Close button string
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeString;

  /// Message shown after pressing Clear All button
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all missed prayers?'**
  String get missedPrayersClearAllMessage;

  /// Add missed prayers dialog string
  ///
  /// In en, this message translates to:
  /// **'Add missed prayers'**
  String get addMissedPrayersTitle;

  /// Add Week button string
  ///
  /// In en, this message translates to:
  /// **'Add Week'**
  String get addWeekString;

  /// Add Month button string
  ///
  /// In en, this message translates to:
  /// **'Add Month'**
  String get addMonthString;

  /// Add Year button string
  ///
  /// In en, this message translates to:
  /// **'Add Year'**
  String get addYearString;

  /// Prayer reminder dialog title
  ///
  /// In en, this message translates to:
  /// **'Prayer reminder'**
  String get reminderDialogTitle;

  /// Prayer reminder dialog message
  ///
  /// In en, this message translates to:
  /// **'Set prayer reminder'**
  String get reminderDialogMessage;

  /// Prayer reminder value message
  ///
  /// In en, this message translates to:
  /// **'Reminder for each prayer: {reminder}'**
  String reminderPrayerMessage(num reminder);

  /// General section string in Settings page
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneralSection;

  /// Language string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Dark Mode string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// Settings automatic daylight saving string
  ///
  /// In en, this message translates to:
  /// **'Automatic Daylight Saving'**
  String get settingsAutoDst;

  /// Settings automatic daylight saving enabled string
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settingsAutoDstEnabled;

  /// Settings automatic daylight saving disabled string
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get settingsAutoDstDisabled;

  /// Daylight Saving string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Daylight Saving'**
  String get settingsDaylightSaving;

  /// Summer Time dialog string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Summer Time'**
  String get settingsSummerTime;

  /// Winter Time dialog string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Winter Time'**
  String get settingsWinterTime;

  /// Notifications section string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsSection;

  /// Send Notifications string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Send Notifications'**
  String get settingsSendNotifications;

  /// Prayer Reminder string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminder'**
  String get settingsPrayerReminder;

  /// Prayer Reminder description string in Settings page
  ///
  /// In en, this message translates to:
  /// **'{reminder} mins'**
  String settingsPrayerReminderDescription(num reminder);

  /// Prayer Reminder description off string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsPrayerReminderDescriptionOff;

  /// Dhikr section string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Tasbeeh'**
  String get settingsDhikrSection;

  /// Vibrate on each Tap string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Vibrate on each Tap'**
  String get settingsDhikrVibrateOnTap;

  /// Vibrate on reaching Target string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Vibrate on finishing Cycle'**
  String get settingsDhikrVibrateOnTarget;

  /// Target string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Cycle length'**
  String get settingsTarget;

  /// Target description string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Current Cycle is: {dhikrTarget}'**
  String settingsTargetDescription(num dhikrTarget);

  /// Help section string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelpSection;

  /// Reset Notifications string in Settings page
  ///
  /// In en, this message translates to:
  /// **'Reset Notifications'**
  String get settingsResetNotifications;

  /// Target Dialog Title string
  ///
  /// In en, this message translates to:
  /// **'Counter target'**
  String get targetDialogTitle;

  /// Language Dialog Title string
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageDialogTitle;

  /// Notification title for when a prayer time arrives
  ///
  /// In en, this message translates to:
  /// **'Time for {prayer}'**
  String notificationsPrayerTimeTitle(String prayer);

  /// Notification title for when a Shuruq time arrives
  ///
  /// In en, this message translates to:
  /// **'Time for Shuruq'**
  String get notificationsShuruqPrayerTimeTitle;

  /// Notification body for Shuruq
  ///
  /// In en, this message translates to:
  /// **'Duha is in 20 minutes'**
  String get notificationsShuruqBody;

  /// Notification title for prayer reminder
  ///
  /// In en, this message translates to:
  /// **'{prayer} Azan is in {reminder} minutes'**
  String notificationsReminderTitle(String prayer, num reminder);

  /// Notification title for prayer reminder - For arabic Locale
  ///
  /// In en, this message translates to:
  /// **'{prayer} Azan is in {reminder} minutes'**
  String notificationsReminderTitleMinutes(String prayer, num reminder);

  /// Notification title for Shuruq reminder
  ///
  /// In en, this message translates to:
  /// **'Shuruq is in {reminder} minutes'**
  String notificationsShuruqReminderTitle(num reminder);

  /// Notification title for Shuruq reminder - For arabic Locale
  ///
  /// In en, this message translates to:
  /// **'Shuruq is in {reminder} minutes'**
  String notificationsShuruqReminderTitleMinutes(num reminder);

  /// City selection string
  ///
  /// In en, this message translates to:
  /// **'Selcet your city'**
  String get citySelect;

  /// Selected city description
  ///
  /// In en, this message translates to:
  /// **'Currnet city'**
  String get cityCurrnet;

  /// City title for Al-Quds
  ///
  /// In en, this message translates to:
  /// **'Al-Quds'**
  String get alQuds;

  /// City title for Kfar Kama
  ///
  /// In en, this message translates to:
  /// **'Kfar Kama'**
  String get kfarKama;

  /// City title for Ramallah
  ///
  /// In en, this message translates to:
  /// **'Ramallah'**
  String get ramallah;

  /// City title for Bethlehem
  ///
  /// In en, this message translates to:
  /// **'Bethlehem'**
  String get bethlehem;

  /// City title for Jenin
  ///
  /// In en, this message translates to:
  /// **'Jenin'**
  String get jenin;

  /// City title for Nablus
  ///
  /// In en, this message translates to:
  /// **'Nablus'**
  String get nablus;

  /// City title for Nazareth
  ///
  /// In en, this message translates to:
  /// **'Nazareth'**
  String get nazareth;

  /// City title for Umm al-Fahm
  ///
  /// In en, this message translates to:
  /// **'Umm al-Fahm'**
  String get ummAlFahm;

  /// City title for Jericho
  ///
  /// In en, this message translates to:
  /// **'Jericho'**
  String get jericho;

  /// City title for Tiberias
  ///
  /// In en, this message translates to:
  /// **'Tiberias'**
  String get tiberias;

  /// City title for Safad
  ///
  /// In en, this message translates to:
  /// **'Safad'**
  String get safad;

  /// City title for Beisan
  ///
  /// In en, this message translates to:
  /// **'Beisan'**
  String get beisan;

  /// City title for Haifa
  ///
  /// In en, this message translates to:
  /// **'Haifa'**
  String get haifa;

  /// City title for Acre
  ///
  /// In en, this message translates to:
  /// **'Acre'**
  String get acre;

  /// City title for Tulkarm
  ///
  /// In en, this message translates to:
  /// **'Tulkarm'**
  String get tulkarm;

  /// City title for Kafr Qasim
  ///
  /// In en, this message translates to:
  /// **'Kafr Qasim'**
  String get kafrQasim;

  /// City title for Tayibe
  ///
  /// In en, this message translates to:
  /// **'Tayibe'**
  String get tayibe;

  /// City title for Al-Khalil
  ///
  /// In en, this message translates to:
  /// **'Al-Khalil'**
  String get alKhalil;

  /// City title for Al-Lid
  ///
  /// In en, this message translates to:
  /// **'Al-Lid'**
  String get alLid;

  /// City title for Ramla
  ///
  /// In en, this message translates to:
  /// **'Ramla'**
  String get ramla;

  /// City title for Qalqilya
  ///
  /// In en, this message translates to:
  /// **'Qalqilya'**
  String get qalqilya;

  /// City title for BirAsSaba
  ///
  /// In en, this message translates to:
  /// **'Bir as-Saba'**
  String get birAsSaba;

  /// City title for Jaffa
  ///
  /// In en, this message translates to:
  /// **'Jaffa'**
  String get jaffa;

  /// City title for Gaza
  ///
  /// In en, this message translates to:
  /// **'Gaza'**
  String get gaza;

  /// City title for Rafah
  ///
  /// In en, this message translates to:
  /// **'Rafah'**
  String get rafah;

  /// City title for Khan Yunis
  ///
  /// In en, this message translates to:
  /// **'Khan Yunis'**
  String get khanYunis;

  /// City title for Deir al-Balah
  ///
  /// In en, this message translates to:
  /// **'Deir al-Balah'**
  String get deirAlBalah;

  /// City title for 1 minute before
  ///
  /// In en, this message translates to:
  /// **'1 minutes before Al-Quds'**
  String get min1BeforeAlQuds;

  /// City title for 3 minute before
  ///
  /// In en, this message translates to:
  /// **'2 minutes before Al-Quds'**
  String get min2BeforeAlQuds;

  /// City title for 3 minute before
  ///
  /// In en, this message translates to:
  /// **'3 minutes before Al-Quds'**
  String get min3BeforeAlQuds;

  /// City title for 1 minute after
  ///
  /// In en, this message translates to:
  /// **'1 minutes after Al-Quds'**
  String get min1AfterAlQuds;

  /// City title for 2 minute after
  ///
  /// In en, this message translates to:
  /// **'2 minutes after Al-Quds'**
  String get min2AfterAlQuds;

  /// City title for 3 minute after
  ///
  /// In en, this message translates to:
  /// **'3 minutes after Al-Quds'**
  String get min3AfterAlQuds;

  /// Notification title when summer time starts tomorrow
  ///
  /// In en, this message translates to:
  /// **'Daylight Saving Time Starts Tomorrow'**
  String get dstSummerNotificationTitle;

  /// Notification body when summer time starts tomorrow
  ///
  /// In en, this message translates to:
  /// **'Clocks will move forward 1 hour tonight. Please be mindful of tomorrow\'s Fajr prayer time.'**
  String get dstSummerNotificationBody;

  /// Notification title when winter time starts tomorrow
  ///
  /// In en, this message translates to:
  /// **'Winter Time Starts Tomorrow'**
  String get dstWinterNotificationTitle;

  /// Notification body when winter time starts tomorrow
  ///
  /// In en, this message translates to:
  /// **'Clocks will move back 1 hour tonight. Please be mindful of tomorrow\'s Fajr prayer time.'**
  String get dstWinterNotificationBody;

  /// Android notification channel name for prayer times
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerNotificationChannelName;

  /// Android notification channel description for prayer times
  ///
  /// In en, this message translates to:
  /// **'Notifications when prayer time arrives'**
  String get prayerNotificationChannelDescription;

  /// Android notification channel name for prayer reminders
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminder'**
  String get reminderNotificationChannelName;

  /// Android notification channel description for prayer reminders
  ///
  /// In en, this message translates to:
  /// **'Reminder notifications before prayer time'**
  String get reminderNotificationChannelDescription;

  /// Android notification channel name for daylight saving alerts
  ///
  /// In en, this message translates to:
  /// **'Daylight Saving Time'**
  String get dstNotificationChannelName;

  /// Android notification channel description for daylight saving alerts
  ///
  /// In en, this message translates to:
  /// **'Notifications for daylight saving time transitions'**
  String get dstNotificationChannelDescription;

  /// Snackbar message showing remaining taps to enable developer mode
  ///
  /// In en, this message translates to:
  /// **'You are {count} steps away from developer mode'**
  String developerModeSteps(int count);

  /// Snackbar message when developer mode is enabled
  ///
  /// In en, this message translates to:
  /// **'Developer mode enabled!'**
  String get developerModeEnabled;

  /// Snackbar message when developer mode is disabled
  ///
  /// In en, this message translates to:
  /// **'Developer mode disabled'**
  String get developerModeDisabled;

  /// Settings and app bar title for notification testing
  ///
  /// In en, this message translates to:
  /// **'Notification Testing'**
  String get notificationTesting;

  /// App version display string
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// Default test notification title for Fajr
  ///
  /// In en, this message translates to:
  /// **'Test Fajr Azan'**
  String get testFajrTitle;

  /// Default test notification body for Fajr
  ///
  /// In en, this message translates to:
  /// **'It is now time for Fajr prayer'**
  String get testFajrBody;

  /// Fallback text when scheduled date is not specified
  ///
  /// In en, this message translates to:
  /// **'Date not specified'**
  String get dateNotSpecified;

  /// Fallback text for relative time when not specified
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// Relative time indicator when notification time has arrived
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get dueNow;

  /// Relative time formatting in days and hours
  ///
  /// In en, this message translates to:
  /// **'in {days}d {hours}h'**
  String inDaysHours(int days, int hours);

  /// Relative time formatting in days only
  ///
  /// In en, this message translates to:
  /// **'in {days}d'**
  String inDays(int days);

  /// Relative time formatting in hours and minutes
  ///
  /// In en, this message translates to:
  /// **'in {hours}h {minutes}m'**
  String inHoursMinutes(int hours, int minutes);

  /// Relative time formatting in hours only
  ///
  /// In en, this message translates to:
  /// **'in {hours}h'**
  String inHours(int hours);

  /// Relative time formatting in minutes only
  ///
  /// In en, this message translates to:
  /// **'in {minutes}m'**
  String inMinutes(int minutes);

  /// Relative time formatting in seconds only
  ///
  /// In en, this message translates to:
  /// **'in {seconds}s'**
  String inSeconds(int seconds);

  /// Default title for instant test notification
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotificationTitle;

  /// Default body for instant test notification
  ///
  /// In en, this message translates to:
  /// **'This is a test notification'**
  String get testNotificationBody;

  /// Default title for scheduled test notification
  ///
  /// In en, this message translates to:
  /// **'Scheduled Test Notification'**
  String get testScheduledNotificationTitle;

  /// Default body for scheduled test notification
  ///
  /// In en, this message translates to:
  /// **'This is a scheduled test notification'**
  String get testScheduledNotificationBody;

  /// Snackbar confirming instant notification was sent
  ///
  /// In en, this message translates to:
  /// **'Instant notification sent'**
  String get instantNotificationSent;

  /// Snackbar confirming notification scheduled in seconds
  ///
  /// In en, this message translates to:
  /// **'Notification scheduled in {seconds} seconds'**
  String notificationScheduledInSeconds(int seconds);

  /// Snackbar confirming cancellation of a notification
  ///
  /// In en, this message translates to:
  /// **'Cancelled notification ({id})'**
  String notificationCancelled(int id);

  /// Snackbar confirming all notifications were cancelled
  ///
  /// In en, this message translates to:
  /// **'All notifications cancelled'**
  String get allNotificationsCancelled;

  /// Tooltip for refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// Status label when permission is granted
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get statusGranted;

  /// Status label when permission is permanently denied
  ///
  /// In en, this message translates to:
  /// **'Permanently Denied'**
  String get statusPermanentlyDenied;

  /// Status label when permission is denied
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get statusDenied;

  /// Status label when exact alarms are restricted
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get statusRestricted;

  /// Header for notification permission section
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermissionStatus;

  /// Description explaining why notification permission is needed
  ///
  /// In en, this message translates to:
  /// **'Android and iOS require permission to display notifications and azan at prayer times.'**
  String get notificationPermissionDescription;

  /// Button label to request notification permission
  ///
  /// In en, this message translates to:
  /// **'Request Permission'**
  String get requestPermission;

  /// Button label to open app settings
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Header for exact alarms permission section
  ///
  /// In en, this message translates to:
  /// **'Exact Alarms Permission'**
  String get exactAlarmsPermission;

  /// Description explaining why exact alarm permission is needed
  ///
  /// In en, this message translates to:
  /// **'Android 12+ requires a special permission to schedule azan and reminders at exact minutes.'**
  String get exactAlarmsDescription;

  /// Button label to request exact alarm permission
  ///
  /// In en, this message translates to:
  /// **'Request Exact Alarm Permission'**
  String get requestExactAlarmsPermission;

  /// Header for test notification sending section
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get sendTestNotificationSection;

  /// Textfield label for notification title
  ///
  /// In en, this message translates to:
  /// **'Notification Title'**
  String get notificationTitleLabel;

  /// Textfield label for notification body
  ///
  /// In en, this message translates to:
  /// **'Notification Body'**
  String get notificationBodyLabel;

  /// Label for schedule delay chips
  ///
  /// In en, this message translates to:
  /// **'Schedule Delay:'**
  String get scheduleDelayLabel;

  /// Label for 1 minute option
  ///
  /// In en, this message translates to:
  /// **'1 min'**
  String get oneMinute;

  /// Label for seconds delay option
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String secondsCount(int seconds);

  /// Button label to send instant notification
  ///
  /// In en, this message translates to:
  /// **'Send Instant'**
  String get sendInstant;

  /// Button label to schedule notification
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// Header for active pending notifications list
  ///
  /// In en, this message translates to:
  /// **'Active Pending Notifications'**
  String get activePendingNotifications;

  /// Description for pending notifications list
  ///
  /// In en, this message translates to:
  /// **'List of notifications currently registered with the OS awaiting trigger time.'**
  String get activePendingNotificationsDescription;

  /// Empty state label when there are no pending notifications
  ///
  /// In en, this message translates to:
  /// **'No pending notifications'**
  String get noPendingNotifications;

  /// Fallback label when notification has no title
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// Tooltip for delete/cancel button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// Button label to cancel all scheduled notifications
  ///
  /// In en, this message translates to:
  /// **'Cancel All Notifications'**
  String get cancelAllNotifications;

  /// Default subject line for contact us email
  ///
  /// In en, this message translates to:
  /// **'Mawaqit Al-Quds App'**
  String get contactUsEmailSubject;

  /// Default body text for contact us email
  ///
  /// In en, this message translates to:
  /// **'Peace be upon you,\n'**
  String get contactUsEmailBody;

  /// Title of the daylight saving dialog
  ///
  /// In en, this message translates to:
  /// **'Daylight saving time'**
  String get daylightSavingDialogTitle;

  /// Status label inside daylight saving dialog
  ///
  /// In en, this message translates to:
  /// **'Daylight saving time is: '**
  String get daylightSavingStatus;

  /// Header for prayer alarms section
  ///
  /// In en, this message translates to:
  /// **'Prayer Alarms'**
  String get alarmSection;

  /// Fajr alarm title
  ///
  /// In en, this message translates to:
  /// **'Fajr Alarm'**
  String get fajrAlarm;

  /// Prayer alarm title
  ///
  /// In en, this message translates to:
  /// **'{prayer} Alarm'**
  String prayerAlarmTitle(String prayer);

  /// Toggle switch label for enabling alarm
  ///
  /// In en, this message translates to:
  /// **'Enable Alarm'**
  String get enableAlarm;

  /// Label for alarm sound selection
  ///
  /// In en, this message translates to:
  /// **'Alarm Sound'**
  String get alarmSound;

  /// Al-Aqsa Adhan option
  ///
  /// In en, this message translates to:
  /// **'Al-Aqsa Mosque Adhan'**
  String get soundAlaqsa;

  /// Makkah Adhan option
  ///
  /// In en, this message translates to:
  /// **'Makkah Adhan'**
  String get soundMakkah;

  /// Madinah Adhan option
  ///
  /// In en, this message translates to:
  /// **'Madinah Adhan'**
  String get soundMadina;

  /// System default alarm option
  ///
  /// In en, this message translates to:
  /// **'System Default Alarm'**
  String get soundSystem;

  /// Silent alarm option with vibration only
  ///
  /// In en, this message translates to:
  /// **'Silent (Vibrate only)'**
  String get soundSilent;

  /// Label for alarm offset
  ///
  /// In en, this message translates to:
  /// **'Alarm Time'**
  String get alarmOffset;

  /// Alarm at exact prayer time
  ///
  /// In en, this message translates to:
  /// **'At prayer time (0m)'**
  String get alarmOffsetExact;

  /// Alarm before prayer time
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before'**
  String alarmOffsetBefore(int minutes);

  /// Snooze button label
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get alarmSnooze;

  /// Snooze duration label
  ///
  /// In en, this message translates to:
  /// **'Snooze Duration'**
  String get alarmSnoozeDuration;

  /// Minutes for snooze
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String alarmSnoozeMinutes(int minutes);

  /// Snooze disabled
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get alarmSnoozeOff;

  /// Dismiss button label
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get alarmDismiss;

  /// Ringing alarm title
  ///
  /// In en, this message translates to:
  /// **'{prayer} Alarm'**
  String alarmRingingTitle(String prayer);

  /// Alarm message when prayer time has arrived
  ///
  /// In en, this message translates to:
  /// **'It is now time for {prayer}'**
  String alarmNowTimeMessage(String prayer);

  /// Alarm message showing minutes left before prayer
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes remaining until {prayer}'**
  String alarmRemainingTimeMessage(int minutes, String prayer);

  /// Wake-up dhikr upon dismissing Fajr alarm
  ///
  /// In en, this message translates to:
  /// **'All praise is for Allah who gave us life after having taken it, and unto Him is the resurrection.'**
  String get alarmWakeupDhikr;

  /// Battery optimization title
  ///
  /// In en, this message translates to:
  /// **'Battery Optimization'**
  String get batteryOptimizationTitle;

  /// Battery optimization description
  ///
  /// In en, this message translates to:
  /// **'To ensure your prayer alarms ring reliably even when the phone is locked, please exempt Mawaqit from battery optimizations.'**
  String get batteryOptimizationDesc;

  /// Battery optimization exempted status
  ///
  /// In en, this message translates to:
  /// **'Exempted (Alarms Reliable)'**
  String get batteryOptimizationDisabled;

  /// Battery optimization active status
  ///
  /// In en, this message translates to:
  /// **'Optimization Active (Alarms May Delay)'**
  String get batteryOptimizationEnabled;

  /// Disable battery optimization button
  ///
  /// In en, this message translates to:
  /// **'Disable Battery Optimization'**
  String get disableBatteryOptimization;

  /// Abdulbasit Abdusamad Adhan option
  ///
  /// In en, this message translates to:
  /// **'Abdulbasit Abdusamad'**
  String get soundAbdulbasit;

  /// El-Minshawi Adhan option
  ///
  /// In en, this message translates to:
  /// **'Mohamed Siddiq El-Minshawi'**
  String get soundMinshawi;

  /// Al-Hussary Adhan option
  ///
  /// In en, this message translates to:
  /// **'Mahmoud Khalil Al-Hussary'**
  String get soundHussary;

  /// Ahmad Al-Nafees Adhan option
  ///
  /// In en, this message translates to:
  /// **'Ahmad Al-Nafees'**
  String get soundNafees;

  /// Title for test alarm card
  ///
  /// In en, this message translates to:
  /// **'Test Prayer Alarm'**
  String get testAlarmTitle;

  /// Description for test alarm
  ///
  /// In en, this message translates to:
  /// **'Trigger a test alarm to verify looping audio, lock screen wake-up, and dismiss/snooze actions.'**
  String get testAlarmDesc;

  /// Button to trigger alarm with delay
  ///
  /// In en, this message translates to:
  /// **'Trigger Alarm in {seconds}s'**
  String triggerAlarmInSeconds(int seconds);

  /// Hint to lock phone for testing
  ///
  /// In en, this message translates to:
  /// **'Tip: Lock your phone right after pressing to verify lock-screen wake-up!'**
  String get testAlarmLockHint;

  /// Title for configured prayer alarms list in testing page
  ///
  /// In en, this message translates to:
  /// **'Configured Prayer Alarms'**
  String get configuredPrayerAlarms;

  /// Description for configured prayer alarms list
  ///
  /// In en, this message translates to:
  /// **'Status and configuration of in-app prayer alarms for each prayer.'**
  String get configuredPrayerAlarmsDesc;

  /// Snackbar message when test alarm scheduled
  ///
  /// In en, this message translates to:
  /// **'Test alarm scheduled in {seconds} seconds. Lock your phone now!'**
  String alarmScheduledInSeconds(int seconds);

  /// Badge showing alarm is active in OS scheduler
  ///
  /// In en, this message translates to:
  /// **'Active in OS'**
  String get activeInOs;

  /// Quick button to test alarm
  ///
  /// In en, this message translates to:
  /// **'Test Alarm (5s)'**
  String get testAlarmButton;

  /// Title for full screen intent permission card
  ///
  /// In en, this message translates to:
  /// **'Full-Screen Alarm Permission'**
  String get fullScreenIntentTitle;

  /// Description for full screen intent permission
  ///
  /// In en, this message translates to:
  /// **'Android 14 requires permission to wake up the screen and show the alarm when your device is locked.'**
  String get fullScreenIntentDesc;

  /// Button to open full screen intent settings
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get fullScreenIntentAction;

  /// Label for alarm delay dropdown
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get alarmDelay;

  /// Status text when full screen intent permission is granted
  ///
  /// In en, this message translates to:
  /// **'Full-screen alarm permission granted'**
  String get fullScreenIntentGranted;

  /// Bottom navigation label for Prayers tab
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get prayersTabString;

  /// Bottom navigation label for Calendar tab
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTabString;

  /// Bottom navigation label and page title for More tab
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreString;

  /// Daylight duration from Shuruq to Maghrib
  ///
  /// In en, this message translates to:
  /// **'Daylight: {hours}h {minutes}m'**
  String daylightDuration(int hours, int minutes);

  /// Fasting duration from Fajr to Maghrib
  ///
  /// In en, this message translates to:
  /// **'Fasting: {hours}h {minutes}m'**
  String fastingDuration(int hours, int minutes);

  /// Settings label for bottom navigation bar style
  ///
  /// In en, this message translates to:
  /// **'Navigation Bar'**
  String get settingsNavBarStyle;

  /// Floating pill navigation bar style option
  ///
  /// In en, this message translates to:
  /// **'Floating'**
  String get navBarStyleFloating;

  /// Docked Material 3 navigation bar style option
  ///
  /// In en, this message translates to:
  /// **'Docked'**
  String get navBarStyleDocked;

  /// Label for Qibla direction angle
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// Label for current device compass heading
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get deviceHeading;

  /// Distance in kilometers to the Kaaba in Makkah
  ///
  /// In en, this message translates to:
  /// **'{km} km to Makkah'**
  String distanceToMakkah(String km);

  /// Status message shown when device is aligned with the Qibla
  ///
  /// In en, this message translates to:
  /// **'Facing the Qibla'**
  String get qiblaAligned;

  /// Instruction message when not yet aligned with the Qibla
  ///
  /// In en, this message translates to:
  /// **'Rotate your phone toward the Kaaba icon'**
  String get qiblaTurnInstruction;

  /// Banner hint when magnetometer needs figure-8 calibration
  ///
  /// In en, this message translates to:
  /// **'Compass accuracy is low. Move your phone in a figure-8 motion to calibrate.'**
  String get qiblaCalibrateHint;

  /// Title when location permission is required for Qibla
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get qiblaLocationPermissionTitle;

  /// Description explaining why GPS location permission is needed for Qibla
  ///
  /// In en, this message translates to:
  /// **'We need your current GPS location to calculate the exact Qibla direction and distance to Makkah wherever you are.'**
  String get qiblaLocationPermissionDesc;

  /// Title when device GPS / location services are disabled
  ///
  /// In en, this message translates to:
  /// **'Location Services Disabled'**
  String get qiblaLocationServicesDisabledTitle;

  /// Description when device GPS / location services are disabled
  ///
  /// In en, this message translates to:
  /// **'Please enable Location Services (GPS) on your device to determine your Qibla direction.'**
  String get qiblaLocationServicesDisabledDesc;

  /// Button label to open location settings
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocationServices;

  /// Loading text while waiting for GPS fix
  ///
  /// In en, this message translates to:
  /// **'Determining your GPS location...'**
  String get qiblaSearchingLocation;

  /// Message when device lacks a magnetometer sensor
  ///
  /// In en, this message translates to:
  /// **'Compass sensor not detected on this device. Showing Qibla angle relative to North.'**
  String get qiblaNoCompassSensor;

  /// Button label to open Google AR Qibla Finder in browser
  ///
  /// In en, this message translates to:
  /// **'Google AR Qibla Finder'**
  String get openArQiblaFinder;

  /// Cardinal North abbreviation
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get northShort;

  /// Cardinal East abbreviation
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get eastShort;

  /// Cardinal South abbreviation
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get southShort;

  /// Cardinal West abbreviation
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get westShort;

  /// Status pill text when magnetometer accuracy is low
  ///
  /// In en, this message translates to:
  /// **'Low compass accuracy — move in a figure-8'**
  String get qiblaCalibrateTitle;

  /// Status pill text when compass sensor has not yet emitted a heading
  ///
  /// In en, this message translates to:
  /// **'Waiting for compass signal...'**
  String get qiblaWaitingForCompass;

  /// Status pill text when device has no compass sensor
  ///
  /// In en, this message translates to:
  /// **'Qibla angle from True North'**
  String get qiblaStaticNorthStatus;

  /// Hint shown if GPS takes too long to lock indoors
  ///
  /// In en, this message translates to:
  /// **'GPS signal is weak. Move near a window or outdoors, or use your selected city temporarily.'**
  String get qiblaWeakGpsHint;

  /// Button label to fall back to selected city coordinates when GPS is weak
  ///
  /// In en, this message translates to:
  /// **'Use {city}'**
  String useSelectedCityFallback(String city);

  /// Banner shown when using city coordinates fallback while GPS continues searching
  ///
  /// In en, this message translates to:
  /// **'Using {city} coordinates while waiting for GPS'**
  String usingCityFallbackBanner(String city);

  /// Short label for Adhan alarm mode card
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get alarmModeAdhan;

  /// Short label for system default alarm mode card
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get alarmModeDefault;

  /// Short label for silent/off alarm mode card
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get alarmModeSilent;

  /// Section header above the pre-prayer offset stepper
  ///
  /// In en, this message translates to:
  /// **'Pre-prayer alarm'**
  String get alarmBeforePrayerSection;

  /// Label on the left of the pre-prayer offset stepper
  ///
  /// In en, this message translates to:
  /// **'Alert before'**
  String get alarmBeforeLabel;

  /// Label when pre-prayer offset is 0 minutes
  ///
  /// In en, this message translates to:
  /// **'At prayer time'**
  String get alarmNoPreAlert;

  /// Short minute value in stepper
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String alarmMinutesValue(int minutes);

  /// Button to apply current prayer alarm settings to all prayers
  ///
  /// In en, this message translates to:
  /// **'Apply this to all prayers'**
  String get alarmApplyToAll;

  /// Snackbar/feedback when alarm settings are applied to all prayers
  ///
  /// In en, this message translates to:
  /// **'Applied to all prayers'**
  String get alarmAppliedToAll;

  /// Title of battery optimization troubleshooting card in alarm sheet
  ///
  /// In en, this message translates to:
  /// **'Alarms not ringing?'**
  String get alarmsNotRingingTitle;

  /// Subtitle of battery optimization troubleshooting card in alarm sheet
  ///
  /// In en, this message translates to:
  /// **'Some Android phones restrict background apps. Tap to exempt Mawaqit from battery optimization.'**
  String get alarmsNotRingingDesc;

  /// Chip/toggle label for vibrate-only mode under Default alarm
  ///
  /// In en, this message translates to:
  /// **'Vibrate only'**
  String get alarmVibrateOnly;

  /// Shows calculated alarm ring time
  ///
  /// In en, this message translates to:
  /// **'Rings at {time}'**
  String alarmRingsAt(String time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
