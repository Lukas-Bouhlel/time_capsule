class Capsule {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final double latitude;
  final double longitude;

  Capsule({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory Capsule.fromJson(Map<String, dynamic> json) {
    return Capsule(
      id: json['id'].toString(),
      title: json['title'] ?? 'Sans titre',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      latitude: json['latitude'] is String ? double.parse(json['latitude']) : (json['latitude'] ?? 0.0),
      longitude: json['longitude'] is String ? double.parse(json['longitude']) : (json['longitude'] ?? 0.0),
    );
  }
}