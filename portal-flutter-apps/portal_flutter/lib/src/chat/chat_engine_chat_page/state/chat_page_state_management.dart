import 'package:flutter/material.dart';
import 'package:glider_portal/glider_portal.dart';

import 'caching/caching.dart';

/// State management model for the Chat Engine chat page.
class ChatPageStateManagement extends ChangeNotifier {
  ChatPageStateManagement({
    required this.secret,
    required this.username,
  }) {
    _fetchChats();
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
    onTypingEvent: _typingEventCache.storeTypingEvent,
  );

  final String secret;
  final String username;

  late final ListCache<int, Chat> _chatCache = ChatCache(api: _api);
  late final ListCache<int, Person> _usersCache = UsersCache(api: _privateApi);

  late final _typingEventCache = TypingEventCache(
    onCacheUpdated: notifyListeners,
  );

  List<String> getUsersTypingInChat(int chatId) {
    return _typingEventCache.getUsersTypingInChat(chatId);
  }

  /// Handles incoming "edit_chat" WebSocket events.
  void _handleEditChatEvent(Chat incomingChat) async {
    _chatCache.cacheValue(incomingChat.id, incomingChat);

    if (activeChatId == incomingChat.id) {
      await _getLatestMessagesForActiveChat();
    }

    notifyListeners();
  }

  /// The chat/conversation selected by the user
  /// that is to be displayed on the chat page.
  Chat? get activeChat => _activeChat;
  Chat? _activeChat;

  /// Indicates if the user is currently viewing a chat.
  bool get withActiveChat => activeChat != null;

  /// The id of the `activeChat`.
  int? get activeChatId => _activeChat?.id;

  /// Set `activeChat` to `chat` and notify listeners.
  Future<void> setActiveChat(Chat? chat) async {
    _activeChat = chat;
    _selectedChatMessages = null;
    notifyListeners();

    await _getLatestMessagesForActiveChat();
    await _fetchChats();
  }

  Future<void> _clearActiveChat() {
    return setActiveChat(null);
  }

  Future<People> getActiveChatMembers() async {
    if (activeChatId != null) {
      final people = (await _chatCache.fetchValue(activeChatId!))?.people;
      final members = people?.map((member) => member.person).toList();

      return members ?? [];
    }
    return [];
  }

  /// Fetch the chats for the given `username` and notify listeners.
  Future<void> _fetchChats() async {
    _fetchingChats = true;
    notifyListeners();
    _chats = await _chatCache.fetchData();
    _chats = _chats.sortByMostRecentActivity();
    _fetchingChats = false;
    notifyListeners();
  }

  /// A list of the current user's chats.
  Chats get chats => _chats.sortByMostRecentActivity();
  Chats _chats = [];
  bool _fetchingChats = true;
  bool get fetchingChats => _fetchingChats;

  /// Create a new chat with the given title and add the
  /// provided usernames to the chat. This will
  /// also set the new chat as the active chat.
  Future<void> createNewChat(String title, List<String> usernamesToAdd) async {
    final response = await _api.createChat(title);
    final newChat = Chat(response.bodyAsJson()!);
    for (final usernameToAdd in usernamesToAdd) {
      await _api.addChatMember(newChat.id, usernameToAdd);
    }
    _chatCache.cacheValue(newChat.id, newChat);
    setActiveChat(newChat);
  }

  /// The list of messages in `activeChat`.
  Messages? get activeChatMessages => _selectedChatMessages;
  Messages? _selectedChatMessages;

  /// Fetch the chat messages for `activeChat`
  Future<void> _getLatestMessagesForActiveChat() async {
    if (activeChatId != null) {
      final response = await _api.getChatMessages(activeChatId!);
      _selectedChatMessages = Message.messagesFromWebResponse(response);
      notifyListeners();
    }
  }

  /// Send a message to the active chat.
  Future<void> sendTextMessage(String message) async {
    if (activeChatId != null) {
      await _api.sendChatMessage(activeChatId!, text: message);
    }
    _fetchChats();
    notifyListeners();
  }

  Future<People> getOtherUsers() async {
    final usernames = await _usersCache.fetchData();
    return usernames.where((user) => user.username != username).toList();
  }

  Future<void> deleteActiveChat() async {
    if (withActiveChat) {
      await _api.deleteChat(activeChatId!);
      _chatCache.deleteValue(activeChatId!);
      await _clearActiveChat();
    }
  }
}
