class PrayerModel {
  final String date;
  final String fajr;
  final String shuruq;
  final String duhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerModel(this.date, this.fajr, this.shuruq, this.duhr, this.asr,
      this.maghrib, this.isha);

  PrayerModel.fromJson(Map<String, dynamic> json)
      : date = json['Date'],
        fajr = json['Fajr'],
        shuruq = json['Shuruq'],
        duhr = json['Duhr'],
        asr = json['Asr'],
        maghrib = json['Maghrib'],
        isha = json['Isha'];

  Map<String, dynamic> toJson() => {
        'date': date,
        'fajr': fajr,
        'shuruq': shuruq,
        'duhr': duhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };
}
