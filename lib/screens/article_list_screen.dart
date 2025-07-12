import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import '../utils/time_utils.dart';
import '../screens/article_detail_screen.dart';
import '../database/article_database.dart';
import '../models/article.dart';

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({super.key});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  bool showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  void _loadArticles() {
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    if (showOnlyFavorites) {
      provider.loadFavorites();
    } else {
      provider.loadArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacker News'),
        actions: [
          IconButton(
            icon: Icon(
              showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: showOnlyFavorites ? Colors.red : null,
            ),
            tooltip: showOnlyFavorites ? 'Voir tout' : 'Voir favoris',
            onPressed: () {
              setState(() {
                showOnlyFavorites = !showOnlyFavorites;
              });
              _loadArticles();
            },
          ),
        ],
      ),
      body:
          provider.loading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? Center(child: Text('Erreur : ${provider.error}'))
              : ListView.separated(
                itemCount: provider.articles.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final article = provider.articles[index];

                  return ListTile(
                    title: Text(article.title),
                    subtitle: Text(
                      'Par @${article.author ?? "?"} · ${timeAgoFromUnix(article.time ?? 0)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${article.descendants ?? 0} 🗨️',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        IconButton(
                          icon: Icon(
                            article.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: article.isFavorite ? Colors.red : null,
                          ),
                          onPressed: () async {
                            await ArticleDatabase.updateFavorite(
                              article.id,
                              !article.isFavorite,
                            );
                            setState(() {
                              provider.articles[index] = Article(
                                id: article.id,
                                title: article.title,
                                author: article.author,
                                time: article.time,
                                descendants: article.descendants,
                                url: article.url,
                                kids: article.kids,
                                isFavorite: !article.isFavorite,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailScreen(article: article),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
