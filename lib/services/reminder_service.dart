import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'store_manager.dart';

class ReminderNotifier with ChangeNotifier {
  int _reminderTime = 10;
  bool _remindrStatus = false;
  int getReminderTime() => _reminderTime;
  bool getReminderStatus() => _remindrStatus;

  ReminderNotifier() {
    StorageManager.readData('Reminder').then((value) {
      _reminderTime = value ?? 10;
      notifyListeners();
    });
    StorageManager.readData('ReminderStatus').then((value) {
      _remindrStatus = value ?? false;
      notifyListeners();
    });
  }

  void setReminderTime(int val) async {
    _reminderTime = val;
    StorageManager.saveData('Reminder', val);
    notifyListeners();
  }

  void setReminderStatus(bool val) async {
    _remindrStatus = val;
    StorageManager.saveData('ReminderStatus', val);
    notifyListeners();
  }
}
