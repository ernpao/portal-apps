import 'package:flutter/foundation.dart';
import 'package:glider_portal/glider_portal.dart';

import 'cache.dart';

class MessageCache extends AbstractListCache<int, Message> {
  MessageCache({
    required this.api,
    required this.chatId,
  });

  /// The interface that will be used
  /// to fetch chat data remotely.
  final ChatEngineAPI api;

  final int chatId;

  @override
  @protected
  int createCacheKeyForValue(Message value) => value.id;

  @override
  @protected
  Future<Message?> fetchSingleValueFromRemote(int key) async {
    final response = await api.getMessageDetails(chatId, key);
    final json = response.bodyAsJson();
    if (json != null) return Message(json);
  }

  @override
  @protected
  Future<Messages> fetchValuesFromRemote() async {
    final response = await api.getLatestChatMessages(chatId, 20);
    return Message.fromJsonArray(response.bodyAsJsonList()!);
  }
}
