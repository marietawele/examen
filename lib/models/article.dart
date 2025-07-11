class Article {
  final int id;
  final String title;
  final String? author; // L'auteur peut être nul
  final int? descendants; // Nombre de commentaires, peut être nul
  final String? url; // Lien de l'article
  final String? type; // Type d'article (story, comment, etc.)
  final int? time; // Timestamp
  final List<int>? kids; // IDs des commentaires enfants

  Article({
    required this.id,
    required this.title,
    this.author,
    this.descendants,
    this.url,
    this.type,
    this.time,
    this.kids,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] ?? 'No Title', // Certains articles (par exemple, des commentaires) peuvent ne pas avoir de titre
      author: json['by'],
      descendants: json['descendants'],
      url: json['url'],
      type: json['type'],
      time: json['time'],
      kids: (json['kids'] as List?)?.cast<int>(),
    );
  }
}