import 'package:flutter/foundation.dart';
import 'package:glider_portal/glider_portal.dart';

class ChatEngineChatState extends ChangeNotifier {
  ChatEngineChatState({
    required this.secret,
    required this.username,
  }) {
    _fetchChats();
  }

  late final api = ChatEngineAPI(username: username, secret: secret);

  final _privateApi = ChatEnginePrivateAPI();

  final String secret;
  final String username;

  List<Chat>? _chats;
  List<Chat>? get chats => _chats;

  Chat? _selectedChat;
  Chat? get selectedChat => _selectedChat;

  Future<void> _fetchChats() async {
    _chats = null;
    final response = await api.getMyChats();
    final jsonArray = response.bodyAsJsonList();
    _chats = jsonArray?.map((e) => Chat(e)).toList();
    notifyListeners();
  }

  /// Create a new chat with the given title and add the
  /// provided usernames to the chat.
  Future<void> createNewChat(String title, List<String> usernamesToAdd) async {
    final response = await api.createChat(title);
    _selectedChat = Chat(response.bodyAsJson()!);

    for (final usernameToAdd in usernamesToAdd) {
      await api.addChatMember(_selectedChat!.id, usernameToAdd);
    }

    _fetchChats();
  }

  Future<List<ChatEngineUser>> getOtherUsers() async {
    debugPrint("Fetching other users...");

    final usernames = <String>[];
    final users = <ChatEngineUser>[];
    final response = await _privateApi.getUsers();
    final jsonArray = response.bodyAsJsonList() ?? [];

    for (final json in jsonArray) {
      final user = ChatEngineUser(json);
      if (user.username != api.username) {
        usernames.add(user.username);
        users.add(user);
      }
    }

    return users;
  }
}
