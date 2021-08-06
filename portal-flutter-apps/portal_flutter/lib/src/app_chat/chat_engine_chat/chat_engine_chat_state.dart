import 'package:flutter/foundation.dart';
import 'package:glider_portal/glider_portal.dart';

class ChatEngineChatState extends ChangeNotifier {
  ChatEngineChatState({
    required this.secret,
    required this.username,
  }) {
    fetchChats();
  }

  late final api = ChatEngineAPI(username: username, secret: secret);

  final String secret;
  final String username;

  List<Chat>? _chats;
  List<Chat>? get chats => _chats;

  Chat? _selectedChat;
  Chat? get selectedChat => _selectedChat;

  Future<List<Chat>?> fetchChats() async {
    final response = await api.getMyChats();
    final jsonArray = response.bodyAsJsonList();
    _chats = jsonArray?.map((e) => Chat(e)).toList();
    return _chats;
  }

  void createNewChat(String title, {bool isDirectChat = false}) async {
    await api.createChat(title, isDirectChat: isDirectChat);
  }
}
