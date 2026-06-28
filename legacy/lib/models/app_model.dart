class AppModel {
  final String name;
  final String appUrl;
  final String description;
  final String imageUrl;

  AppModel(this.name, this.appUrl, this.description, this.imageUrl);

  AppModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        appUrl = json['appUrl'],
        description = json['description'],
        imageUrl = json['imageUrl'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'appUrl': appUrl,
        'description': description,
        'imageUrl': imageUrl,
      };
}
