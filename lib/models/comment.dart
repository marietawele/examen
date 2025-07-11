class Comment {
  final int id;
  final String? author;
  final String? text;
  final int? time;
  final List<int>? children;

  Comment({required this.id, this.author, this.text, this.time, this.children});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      author: json['by'],
      text: json['text'],
      time: json['time'],
      children: (json['kids'] as List?)?.cast<int>(),
    );
  }
}
