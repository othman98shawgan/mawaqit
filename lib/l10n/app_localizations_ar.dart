// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get language => 'العربية';

  @override
  String get appName => 'مواقيت بيت المقدس';

  @override
  String get fajrString => 'الفجر';

  @override
  String get shuruqString => 'الشروق';

  @override
  String get duhrString => 'الظهر';

  @override
  String get asrString => 'العصر';

  @override
  String get maghribString => 'المغرب';

  @override
  String get ishaString => 'العشاء';

  @override
  String timeUntil(String prayer) {
    return 'الوقت المتبقي حتى $prayer:';
  }

  @override
  String timeSince(String prayer) {
    return 'الوقت المنقضي منذ $prayer:';
  }

  @override
  String get calendarString => 'تقويم الصلاة';

  @override
  String get todayTooltip => 'اليوم';

  @override
  String get dstTooltip => 'التوقيت الصيفي/الشتوي';

  @override
  String get prevoiusDayTooltip => 'اليوم السابق';

  @override
  String get nextDayTooltip => 'اليوم التالي';

  @override
  String get qiblaString => 'القبلة';

  @override
  String get ourAppsString => 'تطبيقاتنا';

  @override
  String get contactUsString => 'للتواصل معنا';

  @override
  String get shareString => 'مشاركة';

  @override
  String get shareMessageTitle => 'مواقيت الصلاة ليوم';

  @override
  String get shareMessageDownload =>
      'لتحميل تطبيق مواقيت بيت المقدس عبر متجر جوجل';

  @override
  String get dhikrString => 'المسبحة';

  @override
  String get missedPrayersString => 'الصلوات الفائتة';

  @override
  String get notificationsString => 'التنبيهات';

  @override
  String get cancelPrayersTooltip => 'إلغاء الصلوات';

  @override
  String get settingsString => 'الإعدادات';

  @override
  String get resetCountTooltip => 'تصفير العداد';

  @override
  String get missedPrayersClearAll => 'مسح الكل';

  @override
  String get confirmString => 'تأكيد';

  @override
  String get cancelString => 'إلغاء';

  @override
  String get closeString => 'إغلاق';

  @override
  String get missedPrayersClearAllMessage =>
      'هل أنت متأكد من رغبتك في مسح كل الصلوات الفائتة؟';

  @override
  String get addMissedPrayersTitle => 'إضافة صلوات فائتة';

  @override
  String get addWeekString => 'إضافة أسبوع';

  @override
  String get addMonthString => 'إضافة شهر';

  @override
  String get addYearString => 'إضافة سنة';

  @override
  String get reminderDialogTitle => 'تذكير للصلاة';

  @override
  String get reminderDialogMessage => 'تعيين تذكير للصلاة';

  @override
  String reminderPrayerMessage(num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return 'التذكير لكل صلاة: $reminderString';
  }

  @override
  String get settingsGeneralSection => 'عام';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsDarkMode => 'الوضع الليلي';

  @override
  String get settingsDaylightSaving => 'التوقيت الصيفي';

  @override
  String get settingsSummerTime => 'التوقيت الصيفي';

  @override
  String get settingsWinterTime => 'التوقيت الشتوي';

  @override
  String get settingsNotificationsSection => 'التنبيهات';

  @override
  String get settingsSendNotifications => 'إرسال التنبيهات';

  @override
  String get settingsPrayerReminder => 'تذكير الصلاة';

  @override
  String settingsPrayerReminderDescription(num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return '$reminderString';
  }

  @override
  String get settingsPrayerReminderDescriptionOff => 'معطل';

  @override
  String get settingsDhikrSection => 'المسبحة';

  @override
  String get settingsDhikrVibrateOnTap => 'الاهتزاز عند العد';

  @override
  String get settingsDhikrVibrateOnTarget => 'الاهتزاز في نهاية الدورة';

  @override
  String get settingsTarget => 'الدورة';

  @override
  String settingsTargetDescription(num dhikrTarget) {
    final intl.NumberFormat dhikrTargetNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String dhikrTargetString = dhikrTargetNumberFormat.format(
      dhikrTarget,
    );

    return 'الدورة الحالية هي: $dhikrTargetString';
  }

  @override
  String get settingsHelpSection => 'مساعدة';

  @override
  String get settingsResetNotifications => 'إعادة تعيين التنبيهات';

  @override
  String get targetDialogTitle => 'الهدف';

  @override
  String get languageDialogTitle => 'اللغة';

  @override
  String notificationsPrayerTimeTitle(String prayer) {
    return 'حان موعد صلاة $prayer';
  }

  @override
  String get notificationsShuruqPrayerTimeTitle => 'حان وقت الشروق';

  @override
  String get notificationsShuruqBody => 'صلاة الضحى بعد 20 دقيقة';

  @override
  String notificationsReminderTitle(String prayer, num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return 'أذان صلاة $prayer بعد $reminderString دقيقة';
  }

  @override
  String notificationsReminderTitleMinutes(String prayer, num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return 'أذان صلاة $prayer بعد $reminderString دقائق';
  }

  @override
  String notificationsShuruqReminderTitle(num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return 'الشروق بعد $reminderString دقيقة';
  }

  @override
  String notificationsShuruqReminderTitleMinutes(num reminder) {
    final intl.NumberFormat reminderNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String reminderString = reminderNumberFormat.format(reminder);

    return 'الشروق بعد $reminderString دقائق';
  }

  @override
  String get citySelect => 'اختيار المدينة';

  @override
  String get cityCurrnet => 'المدينة الحالية';

  @override
  String get alQuds => 'القدس';

  @override
  String get kfarKama => 'كفر كما';

  @override
  String get ramallah => 'رام الله';

  @override
  String get bethlehem => 'بيت لحم';

  @override
  String get jenin => 'جنين';

  @override
  String get nablus => 'نابلس';

  @override
  String get nazareth => 'الناصرة';

  @override
  String get ummAlFahm => 'ام الفحم';

  @override
  String get jericho => 'أريحا';

  @override
  String get tiberias => 'طبريا';

  @override
  String get safad => 'صفد';

  @override
  String get beisan => 'بيسان';

  @override
  String get haifa => 'حيفا';

  @override
  String get acre => 'عكا';

  @override
  String get tulkarm => 'طولكرم';

  @override
  String get kafrQasim => 'كفر قاسم';

  @override
  String get tayibe => 'الطيبة';

  @override
  String get alKhalil => 'الخليل';

  @override
  String get alLid => 'اللد';

  @override
  String get ramla => 'الرملة';

  @override
  String get qalqilya => 'قلقيلية';

  @override
  String get birAsSaba => 'بئر السبع';

  @override
  String get jaffa => 'يافا';

  @override
  String get gaza => 'غزة';

  @override
  String get rafah => 'رفح';

  @override
  String get khanYunis => 'خانيونس';

  @override
  String get deirAlBalah => 'دير البلح';

  @override
  String get min1BeforeAlQuds => '1 دقائق قبل القدس';

  @override
  String get min2BeforeAlQuds => '2 دقائق قبل القدس';

  @override
  String get min3BeforeAlQuds => '3 دقائق قبل القدس';

  @override
  String get min1AfterAlQuds => '1 دقائق بعد القدس';

  @override
  String get min2AfterAlQuds => '2 دقائق بعد القدس';

  @override
  String get min3AfterAlQuds => '3 دقائق بعد القدس';
}
