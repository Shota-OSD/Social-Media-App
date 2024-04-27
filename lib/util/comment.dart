class Comment {
  final String senderID;
  final String senderEmail;
  final String postID;
  final String message;
  final DateTime timestamp;

  Comment(
      {required this.senderID,
      required this.senderEmail,
      required this.postID,
      required this.message,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'postID': postID,
      'message': message,
      'timestamp': timestamp
    };
  }
}
