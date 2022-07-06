import 'package:alfajr/ui/counter_page.dart';
import 'package:flutter/material.dart';

import 'services/notifications_service.dart';
import 'ui/counter_page.dart';
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //NotificationsService.initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alfajr',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const MyHomePage(
              title: 'Alfajr',
            ),
        '/counter': (context) => const CounterPage(),
      },
    );
  }
}
