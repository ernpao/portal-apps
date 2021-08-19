import 'package:flutter/foundation.dart';
import 'package:glider_portal/glider_portal.dart';

import 'cache.dart';

class ChatCache extends AbstractListCache<int, Chat> {
  ChatCache({required this.api});

  /// The interface that will be used
  /// to fetch chat data remotely.
  final ChatEngineAPI api;

  @override
  @protected
  int createCacheKeyForValue(Chat value) => value.id;

  @override
  @protected
  Future<Chat?> fetchSingleValueFromRemote(int key) async {
    final response = await api.getChatDetails(key);
    final json = response.bodyAsJson();
    if (json != null) return Chat(json);
  }

  @override
  @protected
  Future<Chats> fetchValuesFromRemote() async {
    final response = await api.getMyLatestChats(10);
    return Chat.chatsFromWebResponse(response);
  }
}
