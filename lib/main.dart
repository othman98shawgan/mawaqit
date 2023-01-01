import 'package:alfajr/services/daylight_time_service.dart';
import 'package:alfajr/ui/calendar_page.dart';
import 'package:alfajr/ui/counter_page.dart';
import 'package:alfajr/ui/mathurat_page.dart';
import 'package:alfajr/ui/missed_prayer_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/reminder_service.dart';
import 'services/theme_service.dart';
import 'ui/home_page.dart';
import 'ui/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //NotificationsService.initNotification();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => DaylightSavingNotifier()),
        ChangeNotifierProvider(create: (context) => ReminderNotifier())
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
              title: 'Alfajr',
              theme: theme.getTheme(),
              initialRoute: '/home',
              routes: {
                '/home': (context) => const MyHomePage(
                      title: 'Alfajr',
                    ),
                '/counter': (context) => const CounterPage(),
                '/missed_prayer': (context) => const MissedPrayerPage(),
                '/calendar': (context) => const CalendarPage(),
                '/mathurat': (context) => const MathuratPage(),
                '/settings': (context) => const SettingsPage(title: 'Settings'),
              },
            ));
  }
}
