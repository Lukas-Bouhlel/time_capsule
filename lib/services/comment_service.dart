import 'dart:convert';
import '../models/comment_model.dart';
import 'api_service.dart';

class CommentService {
  final ApiService _api = ApiService();

  Future<List<Comment>> getComments(String capsuleId) async {
    final response = await _api.request('GET', '/api/comments/$capsuleId');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      print("❌ Erreur GET Comments: Code ${response.statusCode}");
      print("❌ Body: ${response.body}");
      
      if (response.statusCode == 404) {
        return [];
      }
      
      throw Exception('Erreur chargement commentaires: ${response.statusCode}');
    }
  }

  Future<Comment?> postComment(String capsuleId, String content) async {
    final response = await _api.request(
      'POST',
      '/api/comments',
      body: {
        'content': content,
        'capsuleId': int.parse(capsuleId),
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Comment.fromJson(data);
    } else {
      print("❌ Erreur POST Comment: ${response.statusCode} - ${response.body}");
    }
    return null;
  }
}