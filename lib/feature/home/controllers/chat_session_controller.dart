import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:scaffassistant/core/local_storage/user_info.dart';
import 'package:scaffassistant/feature/home/models/chat_session_model.dart';

import '../../../core/const/string_const/api_endpoint.dart';

class ChatSessionController extends GetxController {

  RxBool isLoading = false.obs;
  RxList<ChatSessionModel> chatSessions = <ChatSessionModel>[].obs;

  Future<void> fetchChatSessions() async {

    try{
      final response = await http.get(
        Uri.parse(APIEndPoint.chatSessions),
        headers: {
          'Authorization' : 'Bearer ${UserInfo.getAccessToken()}'
        }
      );

      print("Fetching chat sessions, Status Code: ${response.statusCode}");


      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> sessionsJson = decoded['results'];
        chatSessions.value = sessionsJson.map((json) => ChatSessionModel.fromJson(json)).toList();
      } else {
        print("Failed to load chat sessions: ${response.statusCode}");
      }

    } catch (e) {
      print("Error fetching chat sessions: $e");
    } finally {

    }

  }

}