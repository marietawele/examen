class Article {
  final int id;
  final String title;
  final String? author;
  final int? time;
  final int? descendants;
  final String? url;
  final List<int> kids;
  final bool isFavorite;

  Article({
    required this.id,
    required this.title,
    this.author,
    this.time,
    this.descendants,
    this.url,
    this.kids = const [],
    this.isFavorite = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] ?? 'Sans titre',
      author: json['by'],
      time: json['time'],
      descendants: json['descendants'],
      url: json['url'],
      kids: json['kids'] != null ? List<int>.from(json['kids']) : [],
      isFavorite: false, // 🔴 important pour garder la valeur par défaut
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'time': time,
      'descendants': descendants,
      'url': url,
      'kids': kids.join(','),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      time: map['time'],
      descendants: map['descendants'],
      url: map['url'],
      kids:
          map['kids'] != null && map['kids'].isNotEmpty
              ? map['kids'].split(',').map(int.parse).toList()
              : [],
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
