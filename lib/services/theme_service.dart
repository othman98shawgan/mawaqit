import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:material_ui/material_ui.dart' as mui;
import '../resources/colors.dart';
import 'store_manager.dart';

class ThemeNotifier with ChangeNotifier {
  // ignore: unused_field
  ThemeData? _themeData;
  ThemeData? getTheme() => _themeMode == ThemeMode.light ? lightTheme : darkTheme;

  mui.ThemeData getMaterialUiTheme() => _themeMode == ThemeMode.light ? lightMaterialUiTheme : darkMaterialUiTheme;

  ThemeMode? _themeMode;
  ThemeMode? get themeMode => _themeMode;

  String? _backgroundImage;
  String? get backgroundImage => _backgroundImage;

  ThemeNotifier(ThemeMode themeMode) {
    if (themeMode == ThemeMode.light) {
      _themeData = lightTheme;
      _themeMode = ThemeMode.light;
      _backgroundImage = 'images/bgGreen.png';
    } else {
      if (kDebugMode) {
        print('setting dark theme');
      }
      _themeData = darkTheme;
      _themeMode = ThemeMode.dark;
      _backgroundImage = 'images/bg.png';
    }
    notifyListeners();
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    _themeMode = ThemeMode.dark;
    _backgroundImage = 'images/bg.png';
    StorageManager.saveData('themeMode', 'dark');
    StorageManager.saveData('isDark', true);
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    _themeMode = ThemeMode.light;
    _backgroundImage = 'images/bgGreen.png';
    StorageManager.saveData('themeMode', 'light');
    StorageManager.saveData('isDark', false);
    notifyListeners();
  }

  //=============================================================================
  // Themes
  //=============================================================================

  //*** Dark Theme ***/
  static final _darkSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade600;
      }
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.grey.shade400;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade800;
      }
      if (states.contains(WidgetState.selected)) {
        return darkThemeSwatch;
      }
      return Colors.grey.shade800;
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return Colors.grey.shade500;
    }),
    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Icon(Icons.check, color: darkThemeSwatch);
      }
      return Icon(Icons.close, color: Colors.grey.shade800);
    }),
  );

  static final _darkChipTheme = ChipThemeData(
    color: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return darkThemeSwatch;
      }
      return Colors.grey.shade800;
    }),
    labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'Tajawal'),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
    checkmarkColor: Colors.white,
    side: BorderSide.none,
  );

  static final _lightChipTheme = ChipThemeData(
    color: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return color3;
      }
      return Colors.grey.shade300;
    }),
    labelStyle: const TextStyle(color: Colors.black87, fontFamily: 'Tajawal'),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
    checkmarkColor: Colors.white,
    side: BorderSide.none,
  );

  static final _darkDatePickerTheme = DatePickerThemeData(
    headerBackgroundColor: darkThemeSwatch,
    headerForegroundColor: Colors.white,
    headerHeadlineStyle:
        const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    headerHelpStyle: const TextStyle(fontFamily: 'Tajawal', color: Colors.white70),
    weekdayStyle: const TextStyle(fontFamily: 'Tajawal', color: Colors.white70, fontWeight: FontWeight.bold),
    dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade600;
      }
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.white;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return darkThemeSwatch;
      }
      return null;
    }),
    todayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return darkThemeSwatch;
    }),
    todayBorder: const BorderSide(color: darkThemeSwatch, width: 1.5),
    yearForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade600;
      }
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.white;
    }),
    yearBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return darkThemeSwatch;
      }
      return null;
    }),
    confirmButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: darkThemeSwatch,
      foregroundColor: Colors.white,
      elevation: 2,
      textStyle: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
    ),
    cancelButtonStyle: TextButton.styleFrom(
      foregroundColor: darkThemeSwatch,
      textStyle: const TextStyle(fontFamily: 'Tajawal'),
    ),
  );

  static final _lightDatePickerTheme = DatePickerThemeData(
    backgroundColor: color1,
    headerBackgroundColor: color3,
    headerForegroundColor: Colors.white,
    headerHeadlineStyle:
        const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    headerHelpStyle: const TextStyle(fontFamily: 'Tajawal', color: Colors.white70),
    weekdayStyle: const TextStyle(fontFamily: 'Tajawal', color: Colors.black87, fontWeight: FontWeight.bold),
    dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade400;
      }
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.black87;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return color3;
      }
      return null;
    }),
    todayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return color3;
    }),
    todayBorder: const BorderSide(color: color3, width: 1.5),
    yearForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade400;
      }
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.black87;
    }),
    yearBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return color3;
      }
      return null;
    }),
    dividerColor: Colors.black12,
    confirmButtonStyle: ElevatedButton.styleFrom(
      backgroundColor: color3,
      foregroundColor: Colors.white,
      elevation: 2,
      textStyle: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
    ),
    cancelButtonStyle: TextButton.styleFrom(
      foregroundColor: color3,
      textStyle: const TextStyle(fontFamily: 'Tajawal'),
    ),
  );

  ThemeData get darkTheme => ThemeData(
        fontFamily: 'Tajawal',
        appBarTheme: const AppBarTheme(backgroundColor: appBarColor, foregroundColor: Colors.white),
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: darkThemeSwatch,
          brightness: Brightness.dark,
        ).copyWith(
          brightness: Brightness.dark,
          onSurface: Colors.white,
          onSurfaceVariant: Colors.white70,
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: prayerBgColorDark,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: colorTextDark),
          bodyMedium: TextStyle(color: colorTextDark),
          bodySmall: TextStyle(color: colorTextDark),
        ).apply(
          bodyColor: colorTextDark,
          displayColor: colorTextDark,
        ),
        toggleButtonsTheme: const ToggleButtonsThemeData(
          selectedColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkThemeSwatch,
            foregroundColor: Colors.white,
          ),
        ),
        switchTheme: _darkSwitchTheme,
        chipTheme: _darkChipTheme,
        datePickerTheme: _darkDatePickerTheme,
      );

  //*** Light Theme ***/
  static final _lightSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return states.contains(WidgetState.selected) ? Colors.white : Colors.grey.shade400;
      }
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return const Color(0xFF72796F);
    }),
    trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey.shade300;
      }
      if (states.contains(WidgetState.selected)) {
        return color3;
      }
      return const Color(0xFFE0E3DC);
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.disabled)) {
        return states.contains(WidgetState.selected) ? Colors.transparent : Colors.grey.shade400;
      }
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return const Color(0xFF72796F);
    }),
    thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Icon(Icons.check, color: color3);
      }
      return const Icon(Icons.close, color: Color(0xFFE0E3DC));
    }),
  );

  ThemeData get lightTheme => ThemeData(
        fontFamily: 'Tajawal',
        appBarTheme: AppBarTheme(backgroundColor: color5, foregroundColor: colorTextLight),
        brightness: Brightness.light,
        drawerTheme: const DrawerThemeData(
          backgroundColor: color3,
        ),
        scaffoldBackgroundColor: color1,
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.all(Colors.black),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: color1,
          titleTextStyle: TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          contentTextStyle: TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        dividerColor: Colors.black26,
        focusColor: lightThemeSwatch,
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: prayerBgColorLight,
        ),
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
            iconColor: WidgetStatePropertyAll(Colors.white),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: color3,
            foregroundColor: Colors.white,
          ),
        ),
        switchTheme: _lightSwitchTheme,
        chipTheme: _lightChipTheme,
        datePickerTheme: _lightDatePickerTheme,
        sliderTheme: SliderThemeData(
          activeTrackColor: color3,
          thumbColor: color3,
          inactiveTrackColor: Colors.grey.shade400,
          disabledActiveTrackColor: Colors.grey.shade400,
          disabledInactiveTrackColor: Colors.grey.shade300,
          disabledThumbColor: Colors.grey.shade400,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: greenMaterialColor).copyWith(
          primary: color3,
          secondary: color3,
          onSurface: Colors.black87,
          onSurfaceVariant: Colors.black54,
        ),
      );

  //*** Material UI Themes (for settings_ui v4+) ***/
  mui.ThemeData get darkMaterialUiTheme => mui.ThemeData(
        useMaterial3: true,
        fontFamily: 'Tajawal',
        brightness: Brightness.dark,
        colorScheme: mui.ColorScheme.fromSeed(
          seedColor: darkThemeSwatch,
          brightness: Brightness.dark,
        ),
      );

  mui.ThemeData get lightMaterialUiTheme => mui.ThemeData(
        useMaterial3: true,
        fontFamily: 'Tajawal',
        brightness: Brightness.light,
        colorScheme: mui.ColorScheme.fromSeed(
          seedColor: color3,
          brightness: Brightness.light,
          primary: color3,
        ),
      );
}
