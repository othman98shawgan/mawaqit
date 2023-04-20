import 'package:alfajr/services/store_manager.dart';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'dart:ui' as ui;

class LocaleNotifier extends ChangeNotifier {
  late Locale _locale = const Locale('ar');

  Locale get locale => _locale;
  Locale getLocale() => _locale;

  LocaleNotifier() {
    Future.delayed(Duration.zero, readLocaleFromStorage);
  }

  void readLocaleFromStorage() {
    StorageManager.readData('Locale').then((value) {
      _locale = Locale(value);
      notifyListeners();
    });
  }

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
}
