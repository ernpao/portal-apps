import 'package:flutter/material.dart';
import 'package:glider_portal/glider_portal.dart';

/// State management model for the Chat Engine chat page.
class ChatPageState extends ChangeNotifier {
  ChatPageState({
    required this.secret,
    required this.username,
  }) {
    _fetchUserChats();
    _socket.begin();
  }

  @override
  void dispose() {
    _socket.close();
    super.dispose();
  }

  final _privateApi = ChatEnginePrivateAPI();
  late final _api = ChatEngineAPI(username: username, secret: secret);
  late final _socket = ChatEngineWebSocket(
    username: username,
    secret: secret,
    onEditChatEvent: _handleEditChatEvent,
    onTypingEvent: _handleTypingEvent,
  );

  final String secret;
  final String username;

  /// Handles incoming "edit_chat" WebSocket events.
  void _handleEditChatEvent(Chat incomingChat) async {
    final userChats = _chats ?? [];

    bool chatsUpdated = false;

    if (activeChatId == incomingChat.id) {
      await _getSelectedChatMessages();
    }

    for (var i = 0; i < userChats.length; i++) {
      final chat = userChats[i];
      if (chat.id == incomingChat.id) {
        _chats?.removeAt(i);
        _chats?.insert(i, incomingChat);
        chatsUpdated = true;
      }
    }
    if (chatsUpdated) notifyListeners();
  }

  final Map<int, List<_UserTypingEvent>> _typingUsers = {};

  /// Handles incoming "edit_chat" WebSocket events.
  void _handleTypingEvent(int chatId, String username) async {
    List<_UserTypingEvent> usersTypingInChat = _typingUsers[chatId] ?? [];
    usersTypingInChat.add(_UserTypingEvent(username));

    _typingUsers[chatId] = usersTypingInChat;
    debugPrint("Users typing: $_typingUsers");
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      usersTypingInChat = _typingUsers[chatId] ?? [];
      usersTypingInChat.removeWhere((e) => e.eventExpired);
      debugPrint("Users typing: $_typingUsers");
      notifyListeners();
    });
  }

  List<String> getUsersTypingInChat(int chatId) {
    final usersTypingInChat = _typingUsers[chatId] ?? [];
    final users = <String>[];

    for (final user in usersTypingInChat) {
      if (!user.eventExpired && !users.contains(user.username)) {
        users.add(user.username);
      }
    }

    return users;
  }

  /// The chat/conversation selected by the user
  /// that is to be displayed on the chat page.
  Chat? get activeChat => _activeChat;
  Chat? _activeChat;

  /// The id of the `activeChat`.
  int? get activeChatId => _activeChat?.id;

  /// Set `activeChat` to `chat`
  void setActiveChat(Chat chat) {
    _activeChat = chat;
    _selectedChatMessages = null;
    notifyListeners();
    _getSelectedChatMessages();
  }

  /// Fetch the chats for the given `username`.
  Future<void> _fetchUserChats() async {
    _chats = null;
    final response = await _api.getMyChats();
    final jsonArray = response.bodyAsJsonList();
    _chats = jsonArray?.map((e) => Chat(e)).toList();
    notifyListeners();
  }

  List<Chat>? _chats;

  /// A list of the current user's chats.
  List<Chat>? get chats => _chats;

  /// Create a new chat with the given title and add the
  /// provided usernames to the chat.
  Future<void> createNewChat(String title, List<String> usernamesToAdd) async {
    final response = await _api.createChat(title);
    _activeChat = Chat(response.bodyAsJson()!);
    for (final usernameToAdd in usernamesToAdd) {
      await _api.addChatMember(_activeChat!.id, usernameToAdd);
    }
    _fetchUserChats();
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

  /// The list of messages in `activeChat`.
  List<Message>? get activeChatMessages => _selectedChatMessages;
  List<Message>? _selectedChatMessages;

  /// Fetch the chat messages for `activeChat`
  Future<void> _getSelectedChatMessages() async {
    if (activeChatId != null) {
      final response = await _api.getLatestChatMessages(activeChatId!, 10);
      _selectedChatMessages = Message.fromWebResponse(response);
      notifyListeners();
    }
  }
}

class _UserTypingEvent {
  _UserTypingEvent(this.username);
  final String username;
  late final timestamp = DateTime.now();
  bool get eventExpired => DateTime.now().difference(timestamp).inSeconds > 2;

  @override
  String toString() => "$username: ${timestamp.formattedDateTime}";
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
