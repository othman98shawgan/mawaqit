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
    Locale('en'),
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
    'that was used.',
  );
}
