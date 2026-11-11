import 'package:alfajr/l10n/app_localizations.dart';
import 'package:alfajr/services/store_manager.dart';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'dart:ui' as ui;

Map<String, String> getCitiesMap(AppLocalizations l10n) => {
      'alQuds': l10n.alQuds,
      'kfarKama': l10n.kfarKama,
      'ramallah': l10n.ramallah,
      'bethlehem': l10n.bethlehem,
      'jenin': l10n.jenin,
      'nablus': l10n.nablus,
      'nazareth': l10n.nazareth,
      'ummAlFahm': l10n.ummAlFahm,
      'jericho': l10n.jericho,
      'tiberias': l10n.tiberias,
      'safad': l10n.safad,
      'beisan': l10n.beisan,
      'haifa': l10n.haifa,
      'acre': l10n.acre,
      'tulkarm': l10n.tulkarm,
      'kafrQasim': l10n.kafrQasim,
      'tayibe': l10n.tayibe,
      'alKhalil': l10n.alKhalil,
      'alLid': l10n.alLid,
      'ramla': l10n.ramla,
      'qalqilya': l10n.qalqilya,
      'birAsSaba': l10n.birAsSaba,
      'jaffa': l10n.jaffa,
      'gaza': l10n.gaza,
      'rafah': l10n.rafah,
      'khanYunis': l10n.khanYunis,
      'deirAlBalah': l10n.deirAlBalah,
      'min1BeforeAlQuds': l10n.min1BeforeAlQuds,
      'min2BeforeAlQuds': l10n.min2BeforeAlQuds,
      'min3BeforeAlQuds': l10n.min3BeforeAlQuds,
      'min1AfterAlQuds': l10n.min1AfterAlQuds,
      'min2AfterAlQuds': l10n.min2AfterAlQuds,
      'min3AfterAlQuds': l10n.min3AfterAlQuds,
    };

class LocaleNotifier extends ChangeNotifier {
  Locale _locale;
  String _city;
  late int _timeDiff;

  String get city => _city;
  int get timeDiff => _timeDiff;
  Locale get locale => _locale;

  LocaleNotifier(Locale locale, String city)
      : _city = city,
        _locale = locale {
    _timeDiff = getTimeDiff(city);
  }

  //Locale
  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;

    _locale = locale;
    StorageManager.saveData('Locale', locale.toString());
    var isArabic = locale.toString() == 'ar';
    StorageManager.saveData('isArabic', isArabic);
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
    _timeDiff = getTimeDiff(city);
    _city = city;
    StorageManager.saveData('City', city);
    notifyListeners();
  }

  //TimeDiff
  int getTimeDiff(String city) {
    if (diff0.contains(city)) {
      return 0;
    }
    if (diff1.contains(city)) {
      return 1;
    }
    if (diff2.contains(city)) {
      return 2;
    }
    if (diff3.contains(city)) {
      return 3;
    }
    if (diff4.contains(city)) {
      return 4;
    }
    if (diffMinus1.contains(city)) {
      return -1;
    }
    if (diffMinus2.contains(city)) {
      return -2;
    }
    if (diffMinus3.contains(city)) {
      return -3;
    }
    return 0;
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
