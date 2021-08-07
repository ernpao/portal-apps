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

  final _privateApi = ChatEnginePrivateAPI();

  final String secret;
  final String username;

  List<Chat>? _chats;
  List<Chat>? get chats => _chats;

  Chat? _selectedChat;
  Chat? get selectedChat => _selectedChat;

  void fetchChats() async {
    final response = await api.getMyChats();
    final jsonArray = response.bodyAsJsonList();
    _chats = jsonArray?.map((e) => Chat(e)).toList();
    notifyListeners();
  }

  void createNewChat(String title, {bool isDirectChat = false}) async {
    await api.createChat(title, isDirectChat: isDirectChat);
    notifyListeners();
  }

  Future<List<String>> getOtherUsers() async {
    debugPrint("getOtherUsers");

    final usernames = <String>[];
    final response = await _privateApi.getUsers();
    final jsonArray = response.bodyAsJsonList() ?? [];

    for (final json in jsonArray) {
      final user = ChatEngineUser(json);
      if (user.username != api.username) {
        usernames.add(user.username);
      }
    }

    return usernames;
  }
}
