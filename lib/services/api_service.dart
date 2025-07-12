import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';

class ApiService {
  final baseUrl = 'https://hacker-news.firebaseio.com/v0';

  Future<List<int>> fetchTopStoryIds() async {
    final res = await http.get(Uri.parse('$baseUrl/topstories.json'));
    if (res.statusCode == 200) {
      return List<int>.from(json.decode(res.body));
    } else {
      throw Exception('Échec du chargement des IDs');
    }
  }

  Future<Map<String, dynamic>> fetchItem(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/item/$id.json'));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Échec du chargement de l\'article');
    }
  }

  Future<Comment> fetchComment(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/item/$id.json'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return Comment.fromJson(data);
    } else {
      throw Exception('Erreur lors du chargement du commentaire');
    }
  }

  Future<List<Comment>> fetchComments(List<int> ids) async {
    List<Comment> comments = [];

    for (int id in ids) {
      try {
        final comment = await fetchComment(id);
        comments.add(comment);
      } catch (_) {}
    }

    return comments;
  }
}
