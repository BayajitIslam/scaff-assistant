import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/local_storage/user_info.dart';
import 'package:scaffassistant/feature/home/models/chat_history_model.dart';
import '../../../core/const/string_const/api_endpoint.dart';

class ChatController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<ChatHistoryModel> chatHistory = <ChatHistoryModel>[].obs;
  RxString sessionId = ''.obs;

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

  /// Clear messages
  void clearChat() {
    chatHistory.clear();
    sessionId.value = '';
  }
}
