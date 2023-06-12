import 'package:alfajr/services/store_manager.dart';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'dart:ui' as ui;

class LocaleNotifier extends ChangeNotifier {
  late Locale _locale = const Locale('ar');
  late String _city;
  late int _timeDiff = 0;

  String get city => _city;
  int get timeDiff => _timeDiff;
  Locale get locale => _locale;
  Locale getLocale() => _locale;

  LocaleNotifier() {
    Future.delayed(Duration.zero, readLocaleFromStorage);
  }

  void readLocaleFromStorage() {
    StorageManager.readData('Locale').then((value) {
      var lang = value ?? 'ar';
      _locale = Locale(lang);
      notifyListeners();
    });

    StorageManager.readData('City').then((value) {
      _city = value ?? "alQuds";
      notifyListeners();
    });

    StorageManager.readData('TimeDiff').then((value) {
      _timeDiff = value ?? 0;
      notifyListeners();
    });
  }

  //Locale
  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;

    _locale = locale;
    StorageManager.saveData('Locale', locale.toString());
    notifyListeners();
  }

  ui.TextDirection getTextDirection(Locale locale) {
    if (locale == const Locale('ar')) {
      return ui.TextDirection.rtl;
    }
    return ui.TextDirection.ltr;
  }

  //City
  void setCity(String city) {
    if (diff0.contains(city)) {
      _timeDiff = 0;
    }
    if (diff1.contains(city)) {
      _timeDiff = 1;
    }
    if (diff2.contains(city)) {
      _timeDiff = 2;
    }
    if (diff3.contains(city)) {
      _timeDiff = 3;
    }
    if (diff4.contains(city)) {
      _timeDiff = 4;
    }
    if (diffMinus1.contains(city)) {
      _timeDiff = -1;
    }
    if (diffMinus2.contains(city)) {
      _timeDiff = -2;
    }
    if (diffMinus3.contains(city)) {
      _timeDiff = -3;
    }
    _city = city;
    StorageManager.saveData('City', city);
    notifyListeners();
  }
}

List<String> diff0 = [
  'alQuds',
  'kfarKama',
  'ramallah',
  'bethlehem',
  'jenin',
  'nablus',
  'nazareth',
  'ummAlFahm',
];
List<String> diffMinus1 = ['jericho', 'tiberias', 'safad', 'beisan', 'min1BeforeAlQuds'];
List<String> diffMinus2 = ['min2BeforeAlQuds'];
List<String> diffMinus3 = ['min3BeforeAlQuds'];
List<String> diff1 = [
  'haifa',
  'acre',
  'tulkarm',
  'kafrQasim',
  'tayibe',
  'alKhalil',
  'min1AfterAlQuds'
];
List<String> diff2 = ['alLid', 'ramla', 'qalqilya', 'birAsSaba', 'jaffa', 'min2AfterAlQuds'];
List<String> diff3 = ['gaza', 'min3AfterAlQuds'];
List<String> diff4 = ['rafah', 'khanYunis', 'deirAlBalah'];
