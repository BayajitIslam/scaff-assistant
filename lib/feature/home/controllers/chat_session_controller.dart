import 'package:get/get.dart';
import 'package:scaffassistant/core/constants/api_endpoints.dart';
import 'package:scaffassistant/core/services/api_service.dart';
import 'package:scaffassistant/core/services/snackbar_service.dart';
import 'package:scaffassistant/core/utils/console.dart';
import 'package:scaffassistant/feature/home/models/chat_session_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CHAT SESSION CONTROLLER
/// Handles chat sessions - fetch, create, delete
/// ═══════════════════════════════════════════════════════════════════════════
class ChatSessionController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // Observable States
  // ─────────────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isCreating = false.obs;
  final chatSessions = <ChatSessionModel>[].obs;
  final selectedSession = Rxn<ChatSessionModel>();

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchChatSessions();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fetch All Chat Sessions
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> fetchChatSessions() async {
    Console.divider(label: 'CHAT SESSIONS');
    Console.info('Fetching chat sessions...');

    isLoading.value = true;

    try {
      final response = await ApiService.getAuth(ApiEndpoints.chatSessions);

      Console.api('Response status: ${response.statusCode}');

      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> sessionsJson = data['results'] ?? [];

        // Parse sessions
        chatSessions.value = sessionsJson
            .map((json) => ChatSessionModel.fromJson(json))
            .toList();

        Console.success('Loaded ${chatSessions.length} chat sessions');
      } else {
        Console.error('Failed to load sessions: ${response.message}');
      }
    } catch (e) {
      Console.error('Chat sessions exception: $e');
    } finally {
      isLoading.value = false;
      Console.divider();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Create New Chat Session
  // ─────────────────────────────────────────────────────────────────────────
  Future<ChatSessionModel?> createChatSession({String? title}) async {
    Console.info('Creating new chat session...');

    isCreating.value = true;

    try {
      final response = await ApiService.postAuth(
        ApiEndpoints.chatSessions,
        body: {
          'title': title ?? 'New Chat ${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      Console.api('Response status: ${response.statusCode}');

      if (response.success) {
        final newSession = ChatSessionModel.fromJson(response.data);

        // Add to list
        chatSessions.insert(0, newSession);

        // Select new session
        selectedSession.value = newSession;

        Console.success('Created session: ${newSession.id}');
        return newSession;
      } else {
        Console.error('Failed to create session: ${response.message}');
        SnackbarService.error('Failed to create chat session');
        return null;
      }
    } catch (e) {
      Console.error('Create session exception: $e');
      SnackbarService.error('Something went wrong');
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Delete Chat Session
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> deleteChatSession(String sessionId) async {
    Console.info('Deleting chat session: $sessionId');

    try {
      final response = await ApiService.deleteAuth(
        '${ApiEndpoints.chatSession}/$sessionId/',
      );

      Console.api('Response status: ${response.statusCode}');

      if (response.success || response.statusCode == 204) {
        // Remove from list
        chatSessions.removeWhere((session) => session.id == sessionId);

        // Clear selection if deleted session was selected
        if (selectedSession.value?.id == sessionId) {
          selectedSession.value = null;
        }

        Console.success('Session deleted');
        SnackbarService.success('Chat deleted');
        return true;
      } else {
        Console.error('Failed to delete session: ${response.message}');
        SnackbarService.error('Failed to delete chat');
        return false;
      }
    } catch (e) {
      Console.error('Delete session exception: $e');
      SnackbarService.error('Something went wrong');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Delete with Confirmation
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> deleteWithConfirmation(String sessionId) async {
    final confirmed = await SnackbarService.confirm(
      title: 'Delete Chat',
      message:
          'Are you sure you want to delete this chat? This action cannot be undone.',
      confirmText: 'Delete',
      isDanger: true,
    );

    if (confirmed) {
      await deleteChatSession(sessionId);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Select Session
  // ─────────────────────────────────────────────────────────────────────────
  void selectSession(ChatSessionModel session) {
    selectedSession.value = session;
    Console.info('Selected session: ${session.id}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Refresh Sessions
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> refreshSessions() async {
    Console.info('Refreshing sessions...');
    await fetchChatSessions();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Get Session by ID
  // ─────────────────────────────────────────────────────────────────────────
  ChatSessionModel? getSessionById(String id) {
    try {
      return chatSessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }
}
