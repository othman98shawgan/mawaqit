import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'store_manager.dart';

class DhikrNotifier with ChangeNotifier {
  int _dhikrCount = 100;
  bool _vibrateOnTap = true;
  bool _vibrateOnCountTarget = true;
  
  int getDhikrTarget() => _dhikrCount;
  bool getVibrateOnTap() => _vibrateOnTap;
  bool getVibrateOnCountTarget() => _vibrateOnCountTarget;

  DhikrNotifier() {
    StorageManager.readData('DhikrCount').then((value) {
      _dhikrCount = value ?? 33;
      notifyListeners();
    });
    StorageManager.readData('VibrateOnTap').then((value) {
      _vibrateOnTap = value ?? true;
      notifyListeners();
    });
    StorageManager.readData('VibrateOnCountTarget').then((value) {
      _vibrateOnCountTarget = value ?? true;
      notifyListeners();
    });
  }

  void setDhikrCount(int val) async {
    _dhikrCount = val;
    StorageManager.saveData('DhikrCount', val);
    notifyListeners();
  }

  void enableVibrateOnTap() async {
    _vibrateOnTap = true;
    StorageManager.saveData('VibrateOnTap', true);
    notifyListeners();
  }

  void disableVibrateOnTap() async {
    _vibrateOnTap = false;
    StorageManager.saveData('VibrateOnTap', false);
    notifyListeners();
  }

  void enableVibrateOnCountTarget() async {
    _vibrateOnCountTarget = true;
    StorageManager.saveData('VibrateOnCountTarget', true);
    notifyListeners();
  }

  void disableVibrateOnCountTarget() async {
    _vibrateOnCountTarget = false;
    StorageManager.saveData('VibrateOnCountTarget', false);
    notifyListeners();
  }
}
