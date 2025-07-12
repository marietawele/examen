import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../database/article_database.dart';

class ArticleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Article> _articles = [];
  bool _loading = false;
  String? _error;

  List<Article> get articles => _articles;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadArticles() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final ids = await _apiService.fetchTopStoryIds();
      final limited = ids.take(20);
      final List<Article> loaded = [];

      for (final id in limited) {
        final local = await ArticleDatabase.getArticle(id);
        if (local != null && local.isFavorite) {
          // garder le favori même si l’API plante
          loaded.add(local);
          continue;
        }

        try {
          final data = await _apiService.fetchItem(id);
          if (data['type'] == 'story' && data['title'] != null) {
            final article = Article.fromJson(data);
            final articleWithFlag = Article(
              id: article.id,
              title: article.title,
              author: article.author,
              time: article.time,
              descendants: article.descendants,
              url: article.url,
              kids: article.kids,
              isFavorite: local?.isFavorite ?? false,
            );
            loaded.add(articleWithFlag);
            await ArticleDatabase.insertArticle(articleWithFlag);
          }
        } catch (_) {
          if (local != null && !local.isFavorite) {
            await ArticleDatabase.deleteArticle(id);
          }
        }
      }

      _articles = loaded;
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  /// Charge uniquement les articles marqués comme favoris
  Future<void> loadFavorites() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _articles = await ArticleDatabase.getFavorites();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }
}
