import 'package:shared_preferences/shared_preferences.dart';

Future<int> getReminderTime() async {
  final prefs = await SharedPreferences.getInstance();
  final reminderValue = prefs.getInt('Reminder') ?? 10;
  return reminderValue;
}

Future<void> setReminderTime(int reminderValue) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('Reminder', reminderValue);
}
