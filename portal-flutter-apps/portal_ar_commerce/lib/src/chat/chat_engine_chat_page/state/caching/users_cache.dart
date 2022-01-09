import 'package:flutter/foundation.dart';
import 'package:glider_portal/glider_portal.dart';

import 'cache.dart';

class UsersCache extends AbstractListCache<int, Person> {
  UsersCache({required this.api});

  /// The interface that will be used
  /// to fetch chat data remotely.
  final ChatEnginePrivateAPI api;

  @override
  @protected
  int createCacheKeyForValue(Person value) => value.id;

  @override
  @protected
  Future<Person?> fetchSingleValueFromRemote(int key) async {
    final response = await api.getUser(key);
    final json = response.bodyAsJson();
    if (json != null) return Person(json);
  }

  @override
  @protected
  Future<People> fetchValuesFromRemote() async {
    final response = await api.getUsers();
    return Person.peopleFromWebResponse(response);
  }

  Future<List<String>> fetchUsernames() async {
    final people = await fetchData();
    return people.map((person) => person.username).toList();
  }
}
