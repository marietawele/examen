import 'package:flutter/material.dart';
import 'package:examen/models/article.dart';
import 'package:examen/services/api_service.dart';
import 'package:examen/screens/article_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacker News App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      home: const ArticleListScreen(),
    );
  }
}

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({super.key});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  late Future<List<Article>> _futureArticles;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureArticles = _fetchArticles();
  }

  Future<List<Article>> _fetchArticles() async {
    try {
      final List<int> topStoryIds = await _apiService.fetchTopStoryIds();
      final List<int> limitedIds = topStoryIds.take(20).toList();

      List<Article> articles = [];
      for (int id in limitedIds) {
        final Map<String, dynamic> itemData = await _apiService.fetchItem(id);
        if (itemData['type'] == 'story' && itemData['title'] != null) {
          articles.add(Article.fromJson(itemData));
        }
      }
      return articles;
    } catch (e) {
      print('Erreur lors de la récupération des articles: $e');
      throw Exception("Impossible de récupérer les articles.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hacker News',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<Article>>(
        future: _futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun article trouvé.'));
          } else {
            final articles = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailScreen(article: article),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE avec overlay titre
                        Stack(
                          children: [
                            Image.network(
                              getThumbnailFromId(article.id),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.image, size: 60),
                                    ),
                                  ),
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                color: Colors.black.withOpacity(0.6),
                                child: Text(
                                  article.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Auteur + date
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            'Par @${article.author ?? "?"} · ${timeAgoFromUnix(article.time ?? 0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        // Boutons d'action
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.favorite_border),
                                tooltip: 'Aimer',
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.comment_outlined),
                                tooltip: 'Commenter',
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.share_outlined),
                                tooltip: 'Partager',
                              ),
                              const Spacer(),
                              Text(
                                '${article.descendants ?? 0} commentaires',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Image aléatoire à partir de l'id
String getThumbnailFromId(int id) {
  final imgId = id % 1000;
  return 'https://picsum.photos/id/$imgId/800/400';
}

// Temps relatif : "2h", "3j"
String timeAgoFromUnix(int timestamp) {
  final now = DateTime.now();
  final time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  final diff = now.difference(time);

  if (diff.inMinutes < 1) return 'À l’instant';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} h';
  if (diff.inDays < 7) return '${diff.inDays} j';
  return '${time.day}/${time.month}/${time.year}';
}
