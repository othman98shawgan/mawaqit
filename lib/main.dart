import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/services/dhikr_service.dart';
import 'package:alfajr/services/notifications_service.dart';
import 'package:alfajr/ui/calendar_page.dart';
import 'package:alfajr/ui/counter_page.dart';
import 'package:alfajr/ui/mathurat_page.dart';
import 'package:alfajr/ui/missed_prayer_page.dart';
import 'package:flutter/material.dart';
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
        builder: (context, theme, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Mawaqit Al-Quds',
              theme: theme.getTheme(),
              initialRoute: '/home',
              routes: {
                '/home': (context) => const MyHomePage(
                      title: 'Mawaqit Al-Quds',
                    ),
                '/counter': (context) => const CounterPage(),
                '/missed_prayer': (context) => const MissedPrayerPage(),
                '/calendar': (context) => const CalendarPage(),
                '/mathurat': (context) => const MathuratPage(),
                '/settings': (context) => const SettingsPage(title: 'Settings'),
                '/notifications': (context) => const NotificationsPage(),
              },
            ));
  }
}
