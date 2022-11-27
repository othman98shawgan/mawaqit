import 'package:shared_preferences/shared_preferences.dart';

Future<bool> getSummerTime() async {
  final prefs = await SharedPreferences.getInstance();
  final isSummer = prefs.getBool('isSummer') ?? false;
  return isSummer;
}

Future<void> switchSummerTime() async {
  final prefs = await SharedPreferences.getInstance();
  final isSummer = prefs.getBool('isSummer') ?? false;
  prefs.setBool('isSummer', !isSummer);
}

Future<void> setSummerTime(bool isSummer) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('isSummer', isSummer);
}
