import 'dart:io';
import 'package:alfajr/l10n/l10n.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/services/store_manager.dart';
import 'package:alfajr/ui/our_apps_page.dart';
import 'package:alfajr/l10n/app_localizations.dart';
import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/dhikr_service.dart';
import 'package:alfajr/services/notifications_service.dart';
import 'package:alfajr/ui/calendar_page.dart';
import 'package:alfajr/ui/counter_page.dart';
import 'package:alfajr/ui/mathurat_page.dart';
import 'package:alfajr/ui/missed_prayer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// ignore: depend_on_referenced_packages
import 'package:material_ui/material_ui.dart' as mui;
import 'package:provider/provider.dart';

import 'services/reminder_service.dart';
import 'services/theme_service.dart';
import 'ui/home_page.dart';
import 'ui/notifications_page.dart';
import 'ui/notification_test_page.dart';
import 'ui/settings_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';

bool isWeb = false;
bool isAndroid = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('ar', null);
  } catch (_) {}

  if (kIsWeb) {
    isWeb = true;
  } else if (Platform.isAndroid) {
    isAndroid = true;
  }

  if (!kIsWeb) {
    Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    }).catchError((_) => false);
  }

  final prefs = await StorageManager.init();

  //Theme
  var isDark = StorageManager.readDataFromPrefs('isDark', prefs) ?? true;
  ThemeMode themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

  //Locale
  var isArabic = StorageManager.readDataFromPrefs('isArabic', prefs) ?? true;
  String language = isArabic ? 'ar' : 'en';
  String city = StorageManager.readDataFromPrefs('City', prefs) ?? 'alQuds';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier(themeMode)),
        ChangeNotifierProvider(create: (context) => DaylightSavingNotifier()),
        ChangeNotifierProvider(create: (context) => ReminderNotifier()),
        ChangeNotifierProvider(create: (context) => DhikrNotifier()),
        ChangeNotifierProvider(create: (context) => NotificationsStatusNotifier()),
        ChangeNotifierProvider(create: (context) => LocaleNotifier(Locale(language), city)),
      ],
      child: const MyApp(),
    ),
  );
}

class SundayMaterialLocalizationAr extends MaterialLocalizationAr {
  const SundayMaterialLocalizationAr({
    super.localeName = 'ar',
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });

  @override
  int get firstDayOfWeekIndex => 0; // 0 = Sunday (الأحد)
}

class SundayStartLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const SundayStartLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ar';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    try {
      await initializeDateFormatting('ar', null);
      await GlobalMaterialLocalizations.delegate.load(locale);
      const String localeName = 'ar';
      return SundayMaterialLocalizationAr(
        fullYearFormat: intl.DateFormat.y(localeName),
        compactDateFormat: intl.DateFormat.yMd(localeName),
        shortDateFormat: intl.DateFormat.yMMMd(localeName),
        mediumDateFormat: intl.DateFormat.MMMEd(localeName),
        longDateFormat: intl.DateFormat.yMMMMEEEEd(localeName),
        yearMonthFormat: intl.DateFormat.yMMMM(localeName),
        shortMonthDayFormat: intl.DateFormat.MMMd(localeName),
        decimalFormat: intl.NumberFormat.decimalPattern(localeName),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00', localeName),
      );
    } catch (_) {
      return await GlobalMaterialLocalizations.delegate.load(locale);
    }
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeNotifier, LocaleNotifier>(
        builder: (context, theme, localeProvider, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Mawaqit Al-Quds',
              theme: theme.getTheme(),
              builder: (context, child) => mui.Theme(
                data: theme.getMaterialUiTheme(),
                child: child!,
              ),
              locale: localeProvider.locale,
              initialRoute: '/home',
              routes: {
                '/home': (context) => const MyHomePage(),
                '/counter': (context) => const CounterPage(),
                '/missed_prayer': (context) => const MissedPrayerPage(),
                '/calendar': (context) => const CalendarPage(),
                '/mathurat': (context) => const MathuratPage(),
                '/settings': (context) => const SettingsPage(),
                '/notifications': (context) => const NotificationsPage(),
                '/notification_test': (context) => const NotificationTestPage(),
                '/apps': (context) => const OurAppsPage(),
              },
              supportedLocales: L10n.all,
              localizationsDelegates: [
                const SundayStartLocalizationsDelegate(),
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ));
  }
}
