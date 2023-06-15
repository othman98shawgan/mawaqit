import 'package:alfajr/l10n/l10n.dart';
import 'package:alfajr/services/locale_service.dart';
import 'package:alfajr/ui/our_apps_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/dhikr_service.dart';
import 'package:alfajr/services/notifications_service.dart';
import 'package:alfajr/ui/calendar_page.dart';
import 'package:alfajr/ui/counter_page.dart';
import 'package:alfajr/ui/mathurat_page.dart';
import 'package:alfajr/ui/missed_prayer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'services/reminder_service.dart';
import 'services/theme_service.dart';
import 'ui/home_page.dart';
import 'ui/notifications_page.dart';
import 'ui/settings_page.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => DaylightSavingNotifier()),
        ChangeNotifierProvider(create: (context) => ReminderNotifier()),
        ChangeNotifierProvider(create: (context) => DhikrNotifier()),
        ChangeNotifierProvider(create: (context) => NotificationsStatusNotifier()),
        ChangeNotifierProvider(create: (context) => LocaleNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeNotifier, LocaleNotifier>(
        builder: (context, theme, localeProvider, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Mawaqit Al-Quds',
              theme: theme.getTheme(),
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
                '/apps': (context) => const OurAppsPage(),
              },
              supportedLocales: L10n.all,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ));
  }
}
