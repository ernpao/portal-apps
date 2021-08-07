import 'package:flutter/material.dart';
import 'package:glider_portal/glider_portal.dart';

/// State management model for the Chat Engine chat page.
class ChatPageState extends ChangeNotifier {
  ChatPageState({
    required this.secret,
    required this.username,
  }) {
    _fetchChats();
  }

  final _privateApi = ChatEnginePrivateAPI();
  late final _api = ChatEngineAPI(username: username, secret: secret);

  final String secret;
  final String username;

  List<Chat>? _chats;
  List<Chat>? get chats => _chats;

  Chat? _selectedChat;
  Chat? get selectedChat => _selectedChat;
  int? get selectedChatId => _selectedChat?.id;

  void setSelectedChat(Chat chat) {
    _selectedChat = chat;
    _selectedChatMessages = null;
    notifyListeners();
    _getSelectedChatMessages();
  }

  Future<void> _fetchChats() async {
    _chats = null;
    final response = await _api.getMyChats();
    final jsonArray = response.bodyAsJsonList();
    _chats = jsonArray?.map((e) => Chat(e)).toList();
    notifyListeners();
  }

  /// Create a new chat with the given title and add the
  /// provided usernames to the chat.
  Future<void> createNewChat(String title, List<String> usernamesToAdd) async {
    final response = await _api.createChat(title);
    _selectedChat = Chat(response.bodyAsJson()!);
    for (final usernameToAdd in usernamesToAdd) {
      await _api.addChatMember(_selectedChat!.id, usernameToAdd);
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
      if (user.username != _api.username) {
        usernames.add(user.username);
        users.add(user);
      }
    }

    return users;
  }

  List<Message>? _selectedChatMessages;
  List<Message>? get selectedChatMessages => _selectedChatMessages;
  Future<void> _getSelectedChatMessages() async {
    if (selectedChatId != null) {
      final response = await _api.getChatMessages(selectedChatId!);
      _selectedChatMessages = Message.fromWebResponse(response);
      notifyListeners();
    }
  }
}

class ChatPageStateConsumer extends StatelessWidget {
  const ChatPageStateConsumer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final Widget Function(
    BuildContext context,
    ChatPageState chatDisplayState,
  ) builder;

  @override
  Widget build(BuildContext context) {
    final chatDisplayState = Provider.of<ChatPageState>(context);
    return builder(context, chatDisplayState);
  }
}
