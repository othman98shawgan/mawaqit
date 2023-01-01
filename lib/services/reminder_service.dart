import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'store_manager.dart';

class ReminderNotifier with ChangeNotifier {
  final summer = true;

  late int _reminderTime;
  int getReminderTime() => _reminderTime;

  ReminderNotifier() {
    StorageManager.readData('Reminder').then((value) {
      _reminderTime = value ?? 10;
      notifyListeners();
    });
  }

  void setReminderTime(int val) async {
    _reminderTime = val;
    StorageManager.saveData('Reminder', val);
    notifyListeners();
  }
}
