class Message {
  final String senderID;
  final String senderEmail;
  final String roomID;
  final String message;
  final DateTime timestamp;

  Message(
      {required this.senderID,
      required this.senderEmail,
      required this.roomID,
      required this.message,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'roomID': roomID,
      'message': message,
      'timestamp': timestamp
    };
  }
}
