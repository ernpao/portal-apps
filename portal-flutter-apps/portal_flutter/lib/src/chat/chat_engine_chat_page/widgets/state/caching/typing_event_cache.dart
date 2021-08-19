import 'package:glider_models/glider_models.dart';

class TypingEventCache {
  TypingEventCache({required this.onCacheUpdated});

  final Function() onCacheUpdated;
  final Map<int, List<_TypingEvent>> _eventCache = {};

  /// Handles incoming "edit_chat" WebSocket events.
  void storeTypingEvent(int chatId, String username) {
    _cacheTypingEvent(chatId, username);
    _scheduleCacheCleanup(chatId);
  }

  /// Store a typing event in the cache.
  void _cacheTypingEvent(int chatId, String username) {
    List<_TypingEvent> events = _eventCache[chatId] ?? [];
    events.add(_TypingEvent(username));
    _eventCache[chatId] = events;
    onCacheUpdated.call();
  }

  /// Remove a list of expired typing events in
  /// the cache for a given chat ID.
  void _scheduleCacheCleanup(int chatId) {
    Future.delayed(
      _cacheCleanupDelay,
      () {
        final events = _eventCache[chatId] ?? [];
        events.removeWhere((event) => event.isExpired);
        onCacheUpdated.call();
      },
    );
  }

  /// Returns a list of usernames that are typing based
  /// on the events stored in the cache.
  List<String> getUsersTypingInChat(int chatId) {
    final cachedEvents = _eventCache[chatId] ?? [];
    final users = <String>[];

    for (final event in cachedEvents) {
      if (event.isNotExpired && !users.contains(event.username)) {
        users.add(event.username);
      }
    }

    return users;
  }
}

const _eventExpiryInSeconds = 2;
const _eventLifeSpan = Duration(seconds: _eventExpiryInSeconds);
const _cacheCleanupDelay = Duration(seconds: _eventExpiryInSeconds + 1);

class _TypingEvent {
  _TypingEvent(this.username);
  final String username;
  late final _created = DateTime.now();

  bool get isExpired {
    final timeElapsed = DateTime.now().difference(_created);
    return timeElapsed > _eventLifeSpan;
  }

  bool get isNotExpired => !isExpired;

  @override
  String toString() => "$username: ${_created.formattedDateTime}";
}
