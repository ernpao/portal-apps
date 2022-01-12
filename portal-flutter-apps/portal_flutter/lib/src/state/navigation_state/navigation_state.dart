import 'package:flutter/widgets.dart';
import 'package:glider_portal/glider_portal.dart';

class NavigationState extends ChangeNotifier {
  final List<NavigationItem> items;
  final int initialContentIndex;

  late int _currentIndex;
  NavigationItem get selectedItem => items[_currentIndex];
  Widget get selectedItemContent => selectedItem.content;
  String get selectedItemName => selectedItem.name;
  bool get showHeader => selectedItem.showHeader;

  NavigationState({
    required this.items,
    required this.initialContentIndex,
  }) {
    _currentIndex = initialContentIndex;
  }

  void moveToPageByName(String pageName) {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.name == pageName) {
        moveToPageByIndex(i);
      }
    }
  }

  void moveToPageByIndex(int index) {
    assert(index >= 0 && index < items.length);
    _currentIndex = index;
    notifyListeners();
  }
}

class NavigationItem {
  final IconData icon;
  final String name;
  final Widget content;
  final bool showHeader;

  NavigationItem({
    required this.icon,
    required this.name,
    required this.content,
    this.showHeader = true,
  });
}

class NavigationStateConsumer extends StatelessWidget {
  const NavigationStateConsumer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final Widget Function(
    BuildContext context,
    NavigationState navigationState,
  ) builder;

  @override
  Widget build(BuildContext context) {
    final navigationState = Provider.of<NavigationState>(context);
    return builder(context, navigationState);
  }
}
