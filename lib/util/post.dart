class Post {
  final String userID;
  final String topicID;
  final String title;
  final String content;
  final String? imageURL;
  final DateTime timestamp;
  final List<String>? likes;
  Post(
      {required this.userID,
      required this.topicID,
      required this.title,
      required this.content,
      required this.imageURL,
      required this.timestamp,
      required this.likes});

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'topicID': topicID,
      'title': title,
      'content': content,
      'imageURL': imageURL,
      'timestamp': timestamp,
      'likes': likes,
    };
  }
}
