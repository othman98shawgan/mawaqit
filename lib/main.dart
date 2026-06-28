import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/ui/settings_page.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:mawaqit/l10n/app_localizations.dart';
import 'package:mawaqit/l10n/l10n.dart';

// TODO: Ensure these paths point to your newly migrated V2 files
import 'services/store_manager.dart';
import 'services/theme_service.dart';
import 'services/daylight_time_service.dart';
import 'services/dhikr_service.dart';
import 'services/locale_service.dart';
import 'providers/notifications_status_notifier.dart';
import 'services/reminder_service.dart';
import 'services/notifications_service.dart';
import 'ui/test_notifications_page.dart';

void main() async {
  // 1. Lock the engine until async initialization is complete
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Handle Permissions (We will refactor this to a proper onboarding flow later)
  if (!kIsWeb && Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }

    // Specifically request Exact Alarms permission for Android 14+
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // 3. Initialize Storage & Read Primitive Defaults Awaited
  final prefs = await StorageManager.init();
  await NotificationsService.init();

  final isDark = StorageManager.readDataFromPrefs('isDark', prefs) ?? true;
  final themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

  final isArabic = StorageManager.readDataFromPrefs('isArabic', prefs) ?? true;
  final language = isArabic ? 'ar' : 'en';
  final city = StorageManager.readDataFromPrefs('City', prefs) ?? 'alQuds';

  // 4. Boot the Application Engine
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(themeMode)),
        ChangeNotifierProvider(create: (_) => DaylightSavingNotifier()),
        ChangeNotifierProvider(create: (_) => ReminderNotifier()),
        ChangeNotifierProvider(create: (_) => DhikrNotifier()),
        ChangeNotifierProvider(create: (_) => NotificationsStatusNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier(Locale(language), city)),
      ],
      child: const MawaqitApp(),
    ),
  );
}

class MawaqitApp extends StatelessWidget {
  const MawaqitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch providers for real-time reactivity
    return Consumer2<ThemeNotifier, LocaleNotifier>(
      builder: (context, themeNotifier, localeNotifier, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mawaqit Al-Quds V2',

          // Dynamic Styling & Language
          theme: themeNotifier.getTheme(),
          locale: localeNotifier.locale,

          supportedLocales: L10n.all,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Hardcoded to placeholder until we migrate the UI views
          home: const V2PlaceholderHome(),

          // Preserving your route map for the future
          routes: {
            // '/home': (context) => const MyHomePage(),
            // '/counter': (context) => const CounterPage(),
            // '/missed_prayer': (context) => const MissedPrayerPage(),
            // '/calendar': (context) => const CalendarPage(),
            // '/mathurat': (context) => const MathuratPage(),
            '/settings': (context) => const SettingsPage(),
            // '/notifications': (context) => const NotificationsPage(),
            // '/apps': (context) => const OurAppsPage(),
          },
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
// TEMPORARY PLACEHOLDER TO VERIFY ENGINE COMPILATION
// ----------------------------------------------------------------------
class V2PlaceholderHome extends StatelessWidget {
  const V2PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Engine Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Providers Initialized. Ready for UI.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings Page'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TestNotificationsPage()));
        },
        child: const Icon(Icons.notifications_active),
      ),
    );
  }
}
