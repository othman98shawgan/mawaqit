import 'package:flutter/material.dart';
import 'store_manager.dart';

enum NavBarStyle {
  floating,
  docked,
}

class NavStyleNotifier with ChangeNotifier {
  NavBarStyle _style;

  NavBarStyle get style => _style;
  bool get isFloating => _style == NavBarStyle.floating;

  NavStyleNotifier([NavBarStyle initialStyle = NavBarStyle.floating]) : _style = initialStyle;

  void setStyle(NavBarStyle newStyle) {
    if (_style == newStyle) return;
    _style = newStyle;
    StorageManager.saveData('navBarStyle', newStyle.name);
    notifyListeners();
  }

  static NavBarStyle parseStyle(dynamic value) {
    if (value == NavBarStyle.docked.name) {
      return NavBarStyle.docked;
    }
    return NavBarStyle.floating;
  }
}
