import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'store_manager.dart';

class DaylightSavingNotifier with ChangeNotifier {
  final summer = true;

  bool _summerTime = false;
  bool getSummerTime() => _summerTime;

  DaylightSavingNotifier() {
    StorageManager.readData('isSummer').then((value) {
      _summerTime = value ?? false;
      notifyListeners();
    });
  }

  void setSummerTime() async {
    _summerTime = true;
    StorageManager.saveData('isSummer', true);
    notifyListeners();
  }

  void setWinterTime() async {
    _summerTime = false;
    StorageManager.saveData('isSummer', false);
    notifyListeners();
  }

  void switchSummerTime() async {
    _summerTime = !_summerTime;
    StorageManager.saveData('isSummer', _summerTime);
    notifyListeners();
  }
}
