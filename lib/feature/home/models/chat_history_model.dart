class ChatHistoryModel {
  final String id;        // message id
  final String sessionId; // session id
  final String userId;    // user id
  final String role;      // "user" or "assistant"
  final String content;   // message content
  final DateTime createdAt;

  ChatHistoryModel({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      id: json['id'].toString(),
      sessionId: json['session'],
      userId: json['user'],
      role: json['role'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session': sessionId,
      'user': userId,
      'role': role,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
