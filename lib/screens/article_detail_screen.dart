import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../utils/time_utils.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Comment>> _futureComments;

  @override
  void initState() {
    super.initState();
    _futureComments = _apiService.fetchComments(widget.article.kids ?? []);
  }

  Widget buildComment(Comment comment, {int depth = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, right: 8, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${comment.author ?? "[utilisateur inconnu]"} · ${timeAgoFromUnix(comment.time ?? 0)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (comment.text != null)
            Text(comment.text!.replaceAll(RegExp(r'<[^>]*>'), '')),

          if (comment.kids.isNotEmpty)
            FutureBuilder<List<Comment>>(
              future: _apiService.fetchComments(comment.kids),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                return Column(
                  children:
                      snapshot.data!
                          .map((reply) => buildComment(reply, depth: depth + 1))
                          .toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openInBrowser() async {
    final url =
        widget.article.url ??
        'https://news.ycombinator.com/item?id=${widget.article.id}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d’ouvrir le lien")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.article.title, maxLines: 1)),
      body: Column(
        children: [
          // Remplacement du WebView par un bouton cliquable
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text("Ouvrir l'article"),
              onPressed: _openInBrowser,
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Commentaires',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: _futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucun commentaire.'));
                } else {
                  return ListView(
                    children:
                        snapshot.data!.map((c) => buildComment(c)).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
