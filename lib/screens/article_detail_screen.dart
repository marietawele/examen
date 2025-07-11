import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:examen/models/article.dart';
import 'package:examen/models/comment.dart';
import 'package:examen/services/api_service.dart';

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
    _futureComments = _loadComments();
  }

  Future<List<Comment>> _loadComments() async {
    final ids = widget.article.kids ?? [];
    List<Comment> comments = [];
    for (final id in ids) {
      try {
        final comment = await _apiService.fetchComment(id);
        comments.add(comment);
      } catch (_) {}
    }
    return comments;
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.article.url;

    if (url == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Article")),
        body: const Center(child: Text("Pas de lien disponible.")),
      );
    }

    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        Navigator.pop(context);
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          // WebView
          SizedBox(
            height: 200,
            child: WebViewWidget(
              controller:
                  WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..loadRequest(Uri.parse(url)),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "💬 Commentaires",
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
                  return const Center(
                    child: Text("Erreur chargement commentaires."),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun commentaire."));
                } else {
                  final comments = snapshot.data!;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (_, index) {
                      return CommentWidget(comment: comments[index], level: 0);
                    },
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

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final int level;

  const CommentWidget({super.key, required this.comment, required this.level});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final ApiService _apiService = ApiService();
  List<Comment> _replies = [];

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  void _loadReplies() async {
    final ids = widget.comment.children ?? [];
    for (final id in ids) {
      try {
        final reply = await _apiService.fetchComment(id);
        setState(() => _replies.add(reply));
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0 * widget.level,
        right: 8,
        top: 8,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.comment.author != null)
            Text(
              '@${widget.comment.author}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          if (widget.comment.text != null)
            Text(
              widget.comment.text!.replaceAll(RegExp(r'<[^>]*>'), ''),
              style: const TextStyle(fontSize: 13),
            ),
          const SizedBox(height: 6),
          ..._replies.map(
            (reply) => CommentWidget(comment: reply, level: widget.level + 1),
          ),
        ],
      ),
    );
  }
}
