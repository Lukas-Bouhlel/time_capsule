import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _service = CommentService();
  List<Comment> _comments = [];
  bool _isLoading = false;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;

  Future<void> loadComments(String capsuleId) async {
    _comments = []; 
    _isLoading = true;
    notifyListeners();

    try {
      _comments = await _service.getComments(capsuleId);
    } catch (e) {
      print("Erreur loading comments: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addComment(String capsuleId, String content, String username, int userId) async {
    try {
      final newComment = await _service.postComment(capsuleId, content);
      if (newComment != null) {
        _comments.add(newComment); 
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Erreur ajout commentaire: $e");
    }
    return false;
  }
}