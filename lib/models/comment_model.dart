class Comment {
  final int id;
  final String content;
  final String username;
  final DateTime createdAt;
  final int userId;

  Comment({
    required this.id,
    required this.content,
    required this.username,
    required this.createdAt,
    required this.userId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      username: json['user'] != null ? json['user']['username'] : 'Anonyme',
      createdAt: DateTime.parse(json['createdAt']),
      userId: json['userId'],
    );
  }
}