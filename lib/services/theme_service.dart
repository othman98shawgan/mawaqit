import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../resources/colors.dart';
import 'store_manager.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
    // appBarTheme:
    //     const AppBarTheme(backgroundColor: Color(0xff2C363F), foregroundColor: Colors.white),
    // primaryColor: Colors.black,
    brightness: Brightness.dark,
    // backgroundColor: const Color(0xFF212121),
    // dividerColor: Colors.black12,
    // focusColor: darkThemeSwatch,
    // colorScheme: ColorScheme.fromSwatch(primarySwatch: darkThemeSwatch).copyWith(
    //   secondary: Colors.white,
    //   brightness: Brightness.dark,
    // ),
  );

  final lightTheme = ThemeData(
    appBarTheme: const AppBarTheme(backgroundColor: appBarColor, foregroundColor: Colors.white),
    primaryColor: Colors.white,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroudColor,
    dialogBackgroundColor: backgroudColor,
    dividerColor: Colors.white54,
    focusColor: lightThemeSwatch,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: lightThemeSwatch).copyWith(
      secondary: Colors.black,
      brightness: Brightness.light,
    ),
  );

  late ThemeData _themeData = darkTheme;
  ThemeData getTheme() => _themeData;

  late String _currTheme = 'dark';
  String getThemeStr() => _currTheme;

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((value) {
      if (kDebugMode) {
        print('value read from storage: $value');
      }
      var themeMode = value ?? 'dark';
      if (themeMode == 'light') {
        _themeData = lightTheme;
        _currTheme = 'light';
      } else {
        if (kDebugMode) {
          print('setting dark theme');
        }
        _themeData = darkTheme;
        _currTheme = 'dark';
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    _currTheme = 'dark';
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    _currTheme = 'light';
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}
