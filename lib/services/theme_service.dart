import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../resources/colors.dart';
import 'store_manager.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
    fontFamily: GoogleFonts.tajawal().fontFamily,
    appBarTheme: const AppBarTheme(backgroundColor: appBarColor, foregroundColor: Colors.white),
    brightness: Brightness.dark,

    // backgroundColor: const Color(0xFF212121),
    // dividerColor: Colors.black12,
    // focusColor: darkThemeSwatch,
    colorScheme: ColorScheme.fromSwatch(primarySwatch: darkThemeSwatch).copyWith(
      // secondary: const Color(0xffCFD6DE),
      brightness: Brightness.dark,
    ),
    toggleButtonsTheme: const ToggleButtonsThemeData(
      selectedColor: Colors.white,
    ),
  );

  final lightTheme = ThemeData(
    fontFamily: GoogleFonts.tajawal().fontFamily,
    appBarTheme: AppBarTheme(backgroundColor: color5, foregroundColor: colorTextLight),
    brightness: Brightness.light,
    drawerTheme: const DrawerThemeData(
      backgroundColor: color3,
    ),
    scaffoldBackgroundColor: color1,
    dialogBackgroundColor: color1,
    dividerColor: Colors.black26,
    focusColor: lightThemeSwatch,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(),
      bodyMedium: TextStyle(),
      bodySmall: TextStyle(),
    ).apply(
      bodyColor: colorTextLight,
      displayColor: colorTextLight,
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        iconColor: MaterialStatePropertyAll(Colors.white),
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: greenMaterialColor).copyWith(),
  );

  late ThemeData _themeData = darkTheme;
  ThemeData getTheme() => _themeData;

  late String _currTheme = 'dark';
  String getThemeStr() => _currTheme;

  late String _backgroundImage = 'images/bg.png';
  String get backgroundImage => _backgroundImage;

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((value) {
      if (kDebugMode) {
        print('value read from storage: $value');
      }
      var themeMode = value ?? 'dark';
      if (themeMode == 'light') {
        _themeData = lightTheme;
        _currTheme = 'light';
        _backgroundImage = 'images/bgGreen.png';
      } else {
        if (kDebugMode) {
          print('setting dark theme');
        }
        _themeData = darkTheme;
        _currTheme = 'dark';
        _backgroundImage = 'images/bg.png';
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    _currTheme = 'dark';
    _backgroundImage = 'images/bg.png';
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    _currTheme = 'light';
    _backgroundImage = 'images/bgGreen.png';
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}
