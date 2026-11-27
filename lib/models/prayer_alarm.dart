class PrayerAlarmSettings {
  static const String modeAlarm = 'alarm';
  static const String modeNotification = 'notification';
  static const String modeOff = 'off';

  final String prayerName; // 'Fajr', 'Shuruq', 'Duhr', 'Asr', 'Maghrib', 'Isha'
  final String alertMode; // 'alarm', 'notification', 'off'
  final bool isEnabled; // true when alertMode == 'alarm' (kept for backward compatibility)
  final int offsetMinutes; // e.g. 0, -5, -10, -15, -20, -30, -45, -60
  final String soundType; // 'alaqsa', 'makkah', 'madina', 'abdulbasit', 'minshawi', 'hussary', 'nafees', 'system', 'silent'
  final int snoozeMinutes; // 5, 10, 15, 0 (0 = disabled)
  final bool vibrate;
  final bool reminderEnabled; // optional pre-prayer notification reminder
  final int reminderMinutes; // e.g. 5, 10, 15, ..., 60

  const PrayerAlarmSettings({
    required this.prayerName,
    String? alertMode,
    bool isEnabled = false,
    this.offsetMinutes = 0,
    this.soundType = 'alaqsa',
    this.snoozeMinutes = 10,
    this.vibrate = true,
    this.reminderEnabled = false,
    this.reminderMinutes = 10,
  })  : alertMode = alertMode ?? (isEnabled ? modeAlarm : modeOff),
        isEnabled = (alertMode ?? (isEnabled ? modeAlarm : modeOff)) == modeAlarm;

  bool get isAlarm => alertMode == modeAlarm;
  bool get isNotification => alertMode == modeNotification;
  bool get isOff => alertMode == modeOff;
  bool get isAlertActive => alertMode != modeOff;

  static String _normalizeAlertMode(dynamic rawMode, bool legacyEnabled) {
    if (rawMode == modeAlarm || rawMode == modeNotification || rawMode == modeOff) {
      return rawMode as String;
    }
    return legacyEnabled ? modeAlarm : modeOff;
  }

  Map<String, dynamic> toJson() => {
        'prayerName': prayerName,
        'alertMode': alertMode,
        'isEnabled': isEnabled,
        'offsetMinutes': offsetMinutes,
        'soundType': soundType,
        'snoozeMinutes': snoozeMinutes,
        'vibrate': vibrate,
        'reminderEnabled': reminderEnabled,
        'reminderMinutes': reminderMinutes,
      };

  factory PrayerAlarmSettings.fromJson(Map<String, dynamic> json) {
    final legacyEnabled = json['isEnabled'] as bool? ?? false;
    final resolvedMode = _normalizeAlertMode(json['alertMode'], legacyEnabled);
    return PrayerAlarmSettings(
      prayerName: json['prayerName'] as String? ?? 'Fajr',
      alertMode: resolvedMode,
      isEnabled: resolvedMode == modeAlarm,
      offsetMinutes: json['offsetMinutes'] as int? ?? 0,
      soundType: json['soundType'] as String? ?? 'alaqsa',
      snoozeMinutes: json['snoozeMinutes'] as int? ?? 10,
      vibrate: json['vibrate'] as bool? ?? true,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderMinutes: json['reminderMinutes'] as int? ?? 10,
    );
  }

  PrayerAlarmSettings copyWith({
    String? prayerName,
    String? alertMode,
    bool? isEnabled,
    int? offsetMinutes,
    String? soundType,
    int? snoozeMinutes,
    bool? vibrate,
    bool? reminderEnabled,
    int? reminderMinutes,
  }) {
    final String nextMode;
    if (alertMode != null) {
      nextMode = alertMode;
    } else if (isEnabled != null) {
      nextMode = isEnabled ? modeAlarm : modeOff;
    } else {
      nextMode = this.alertMode;
    }

    return PrayerAlarmSettings(
      prayerName: prayerName ?? this.prayerName,
      alertMode: nextMode,
      isEnabled: nextMode == modeAlarm,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      soundType: soundType ?? this.soundType,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      vibrate: vibrate ?? this.vibrate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }
}
