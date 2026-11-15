class MathuratModel {
  final String id;
  final int count;
  final String text;
  final String? eveningText;
  final String? english;
  final String? englishEvening;
  final String period; // 'morning', 'evening', or 'both'
  final String? hadith;

  MathuratModel(
    this.id,
    this.count,
    this.text, {
    this.eveningText,
    this.english,
    this.englishEvening,
    this.period = 'both',
    this.hadith,
  });

  String textFor({required bool isEvening}) =>
      isEvening && eveningText != null && eveningText!.isNotEmpty ? eveningText! : text;

  String? englishFor({required bool isEvening}) =>
      isEvening && englishEvening != null && englishEvening!.isNotEmpty ? englishEvening : english;

  MathuratModel.fromJson(Map<String, dynamic> json)
      : id = json['Id'].toString(),
        count = int.parse(json['Count'].toString()),
        text = json['Text'] as String,
        eveningText = json['EveningText'] as String?,
        english = json['English'] as String?,
        englishEvening = json['EnglishEvening'] as String?,
        period = (json['Period'] as String?) ?? 'both',
        hadith = json['Hadith'] as String?;

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Count': count,
        'Text': text,
        if (eveningText != null) 'EveningText': eveningText,
        if (english != null) 'English': english,
        if (englishEvening != null) 'EnglishEvening': englishEvening,
        'Period': period,
        if (hadith != null) 'Hadith': hadith,
      };
}
