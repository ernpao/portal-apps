import 'package:flutter/foundation.dart';
import 'package:glider_portal/glider_portal.dart';

import 'cache.dart';
import 'message_cache.dart';

class ChatMessagesCache extends AbstractListCache<int, MessageCache> {
  ChatMessagesCache({required this.api});

  /// The interface that will be used
  /// to fetch chat data remotely.
  final ChatEngineAPI api;

  @override
  @protected
  int createCacheKeyForValue(MessageCache value) => value.chatId;

  @override
  @protected
  Future<MessageCache?> fetchSingleValueFromRemote(int key) async {
    final response = await api.getChatMessages(key);
    final messages = Message.messagesFromWebResponse(response);

    final messageCache = MessageCache(api: api, chatId: key);
    messageCache.cacheValues(messages);

    return messageCache;
  }

  DateTime? _oldestChatCreatedOn;
  @override
  @protected
  Future<List<MessageCache>> fetchValuesFromRemote() async {
    List<MessageCache> messageCaches = [];
    Chats chats;
    if (_oldestChatCreatedOn == null) {
      final response = await api.getMyLatestChats(10);
      chats = Chat.chatsFromWebResponse(response);
    } else {
      final response = await api.getMyLatestChatsBeforeTime(
        _oldestChatCreatedOn!,
        10,
      );
      chats = Chat.chatsFromWebResponse(response);
    }

    if (chats.isNotEmpty) {
      _oldestChatCreatedOn = chats.first.created;
    }

    return messageCaches;
  }
}
