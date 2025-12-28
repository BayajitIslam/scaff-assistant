/// ═══════════════════════════════════════════════════════════════════════════
/// CHAT SESSION MODEL
/// Represents a chat session/conversation
/// ═══════════════════════════════════════════════════════════════════════════
class ChatSessionModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.updatedAt,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // From JSON
  // ─────────────────────────────────────────────────────────────────────────
  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled Chat',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // To JSON
  // ─────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Copy With
  // ─────────────────────────────────────────────────────────────────────────
  ChatSessionModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatSessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Formatted Date
  // ─────────────────────────────────────────────────────────────────────────
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  String toString() {
    return 'ChatSessionModel(id: $id, title: $title, createdAt: $createdAt)';
  }
}
