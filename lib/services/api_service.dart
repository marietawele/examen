import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';

class ApiService {
  static const String _baseUrl = 'https://hacker-news.firebaseio.com/v0';

  Future<List<int>> fetchTopStoryIds() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/topstories.json?print=pretty'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> ids = json.decode(response.body);
      return ids.cast<int>();
    } else {
      throw Exception('Failed to load top stories');
    }
  }

  Future<Comment> fetchComment(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/item/$id.json?print=pretty'),
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Comment.fromJson(jsonData);
    } else {
      throw Exception('Erreur chargement commentaire $id');
    }
  }

  Future<Map<String, dynamic>> fetchItem(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/item/$id.json?print=pretty'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load item $id');
    }
  }
}
