/// ═══════════════════════════════════════════════════════════════════════════
/// CHAT HISTORY MODEL
/// Represents a single chat message in a session
/// ═══════════════════════════════════════════════════════════════════════════
class ChatHistoryModel {
  final String id;
  final String sessionId;
  final String userId;
  final String role; // "user" or "assistant"
  final String content;
  final DateTime createdAt;

  ChatHistoryModel({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Check if message is from user
  // ─────────────────────────────────────────────────────────────────────────
  bool get isUser => role == 'user';

  // ─────────────────────────────────────────────────────────────────────────
  // Check if message is from assistant
  // ─────────────────────────────────────────────────────────────────────────
  bool get isAssistant => role == 'assistant';

  // ─────────────────────────────────────────────────────────────────────────
  // From JSON
  // ─────────────────────────────────────────────────────────────────────────
  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      id: json['id']?.toString() ?? '',
      sessionId: json['session']?.toString() ?? '',
      userId: json['user']?.toString() ?? '',
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // To JSON
  // ─────────────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  // Create User Message
  // ─────────────────────────────────────────────────────────────────────────
  factory ChatHistoryModel.userMessage({
    required String content,
    required String sessionId,
    required String userId,
  }) {
    return ChatHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      userId: userId,
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Create Assistant Message
  // ─────────────────────────────────────────────────────────────────────────
  factory ChatHistoryModel.assistantMessage({
    required String content,
    required String sessionId,
    required String userId,
  }) {
    return ChatHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      userId: userId,
      role: 'assistant',
      content: content,
      createdAt: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Formatted Time
  // ─────────────────────────────────────────────────────────────────────────
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  String toString() {
    return 'ChatHistoryModel(id: $id, role: $role, content: ${content.substring(0, content.length > 30 ? 30 : content.length)}...)';
  }
}
