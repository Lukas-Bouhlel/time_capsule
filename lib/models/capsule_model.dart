class Capsule {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String author;

  Capsule({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.author,
  });

  factory Capsule.fromJson(Map<String, dynamic> json) {
    String? img = json['imageUrl']?.toString();
    if (img != null && img.contains('localhost')) {
      img = img.replaceAll('localhost', '10.0.2.2');
    }

    return Capsule(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: img,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      author: json['author'] ?? 'Inconnu',
    );
  }
}
