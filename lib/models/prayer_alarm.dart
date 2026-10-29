class PrayerAlarmSettings {
  final String prayerName; // 'Fajr', 'Shuruq', 'Duhr', 'Asr', 'Maghrib', 'Isha'
  final bool isEnabled;
  final int offsetMinutes; // e.g. 0, -10, -15, -20, -30, -45, -60
  final String soundType; // 'alaqsa', 'makkah', 'madina', 'chime', 'system'
  final int snoozeMinutes; // 5, 10, 0 (0 = disabled)
  final bool vibrate;

  const PrayerAlarmSettings({
    required this.prayerName,
    this.isEnabled = false,
    this.offsetMinutes = 0,
    this.soundType = 'alaqsa',
    this.snoozeMinutes = 10,
    this.vibrate = true,
  });

  Map<String, dynamic> toJson() => {
        'prayerName': prayerName,
        'isEnabled': isEnabled,
        'offsetMinutes': offsetMinutes,
        'soundType': soundType,
        'snoozeMinutes': snoozeMinutes,
        'vibrate': vibrate,
      };

  factory PrayerAlarmSettings.fromJson(Map<String, dynamic> json) => PrayerAlarmSettings(
        prayerName: json['prayerName'] as String? ?? 'Fajr',
        isEnabled: json['isEnabled'] as bool? ?? false,
        offsetMinutes: json['offsetMinutes'] as int? ?? 0,
        soundType: json['soundType'] as String? ?? 'alaqsa',
        snoozeMinutes: json['snoozeMinutes'] as int? ?? 10,
        vibrate: json['vibrate'] as bool? ?? true,
      );

  PrayerAlarmSettings copyWith({
    String? prayerName,
    bool? isEnabled,
    int? offsetMinutes,
    String? soundType,
    int? snoozeMinutes,
    bool? vibrate,
  }) {
    return PrayerAlarmSettings(
      prayerName: prayerName ?? this.prayerName,
      isEnabled: isEnabled ?? this.isEnabled,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      soundType: soundType ?? this.soundType,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      vibrate: vibrate ?? this.vibrate,
    );
  }
}
