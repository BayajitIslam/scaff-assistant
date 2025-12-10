import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/local_storage/user_info.dart';
import 'package:scaffassistant/feature/home/controllers/chat_session_controller.dart';
import 'package:scaffassistant/feature/home/models/chat_history_model.dart';
import '../../../core/const/string_const/api_endpoint.dart';

class ChatController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isSending = false.obs;
  RxList<ChatHistoryModel> chatHistory = <ChatHistoryModel>[].obs;
  RxString sessionId = ''.obs;
  TextEditingController messageController = TextEditingController();

  /// Fetch messages for a specific session
  Future<void> fetchChatMessages(String session) async {
    sessionId.value = session;
    isLoading.value = true;

    try {
      final url = Uri.parse('${APIEndPoint.chatSession}/$session/messages/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${UserInfo.getAccessToken()}',
        },
      );

      print("Fetching messages for session $session, Status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> messagesJson = decoded['messages'];

        chatHistory.value = messagesJson
            .map((json) => ChatHistoryModel.fromJson(json))
            .toList();

        print("Loaded ${chatHistory.length} messages for session $session");
      } else {
        print("Failed to load messages: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching chat messages: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Send a new message
  Future<void> sendMessage() async {
    print("Sending message...");
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message immediately
    final userMessage = ChatHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId.value,
      userId: 'current_user',
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    chatHistory.add(userMessage);
    messageController.clear();

    isSending.value = true;

    try {
      isSending.value = true;

      final bodyWithSession = {
        'question': text,
        'session_id': sessionId.value,
      };
      final bodyWithoutSession = {
        'question': text,
      };

      final body = sessionId.value.isNotEmpty ? bodyWithSession : bodyWithoutSession;

      final url = Uri.parse(APIEndPoint.chatMessages);
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${UserInfo.getAccessToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("Sending message, Status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if(sessionId.value.isEmpty){
          final ChatSessionController chatSessionController = Get.put(ChatSessionController());
          await chatSessionController.fetchChatSessions();
        }

        // Update session ID
        sessionId.value = data['session_id'];

        // Add assistant message
        final assistantMessage = ChatHistoryModel(
          id: data['message_id'].toString(),
          sessionId: data['session_id'],
          userId: 'assistant',
          role: 'assistant',
          content: data['answer'] ?? '', // <-- must use 'answer'
          createdAt: DateTime.now(),
        );

        chatHistory.add(assistantMessage); // triggers UI update
        isSending.value = false;
      } else {
        print("Failed to send message: ${response.statusCode}");
        isSending.value = false;
      }
    } catch (e) {
      print("Error sending message: $e");
      isSending.value = false;
    } finally {
      isSending.value = false;
    }
  }




  /// Clear messages
  void clearChat() {
    chatHistory.clear();
    sessionId.value = '';
  }
}
