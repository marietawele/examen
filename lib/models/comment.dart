class Comment {
  final int id;
  final String? author;
  final String? text;
  final int? time;
  final List<int> kids;

  Comment({
    required this.id,
    this.author,
    this.text,
    this.time,
    required this.kids,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      author: json['by'],
      text: json['text'],
      time: json['time'],
      kids: json['kids'] != null ? List<int>.from(json['kids']) : [],
    );
  }
}
