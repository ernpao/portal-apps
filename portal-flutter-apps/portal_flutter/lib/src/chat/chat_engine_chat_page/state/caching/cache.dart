import 'package:flutter/foundation.dart';
import 'package:glider_portal/glider_portal.dart';

abstract class Cache<K, V> {
  /// Fetch the value stored in the cache
  /// with the given `key`.
  Future<V?> fetchValue(K key);

  /// Store a `value` in the cache with the
  /// given `key`.
  void cacheValue(K key, V? value);
}

/// A cache for lists of items as opposed to a single
/// value.
abstract class ListCache<K, V> extends Cache<K, V> {
  /// Fetch all the values stored in the cache.
  Future<List<V>> fetchData();

  /// Store a list of `values` in the cache.
  void cacheValues(List<V> values);
}

abstract class AbstractCache<K, V> implements Cache<K, V> {
  final Map<K, V?> _cache = {};
  V? _getCachedValue(K key) => _cache[key];

  @override
  Future<V?> fetchValue(K key) async {
    V? cachedValue = _getCachedValue(key);
    if (cachedValue == null) {
      log("Fetching single value from remote...");
      final valueFromRemote = await fetchSingleValueFromRemote(key);
      cacheValue(key, valueFromRemote);
      return valueFromRemote;
    } else {
      return cachedValue;
    }
  }

  @protected
  Future<V?> fetchSingleValueFromRemote(K key);

  /// Create a key for the value that
  /// this cache will store.
  @protected
  K createCacheKeyForValue(V value);

  @override
  void cacheValue(K key, V? value) {
    _cache[key] = value;
  }
}

abstract class AbstractListCache<K, V> extends AbstractCache<K, V>
    implements ListCache<K, V> {
  AbstractListCache({
    this.refreshInterval = const Duration(minutes: 5),
  });

  @override
  Future<List<V>> fetchData() async {
    if (_fetchFromRemoteRequired) {
      log("Fetching values from remote...");
      final values = await fetchValuesFromRemote();
      _lastFetchFromRemote = DateTime.now();
      cacheValues(values);
    }
    return _cachedValues;
  }

  List<V> get _cachedValues => _cache.getNonNullValues<V>();
  DateTime? _lastFetchFromRemote;
  final Duration refreshInterval;

  @override
  void cacheValues(List<V> values) {
    for (final value in values) {
      final key = createCacheKeyForValue(value);
      cacheValue(key, value);
    }
  }

  @protected
  bool get _fetchFromRemoteRequired {
    if (_cache.isEmpty) return true;
    if (_lastFetchFromRemote == null) return true;

    final elapsed = DateTime.now().difference(_lastFetchFromRemote!);
    return elapsed > refreshInterval;
  }

  @protected
  Future<List<V>> fetchValuesFromRemote();
}
