class MathuratModel {
  final String id;
  final int count;
  final String text;

  MathuratModel(this.id, this.count, this.text);

  MathuratModel.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        count = int.parse(json['Count']),
        text = json['Text'];

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Count': count,
        'Text': text,
      };
}
